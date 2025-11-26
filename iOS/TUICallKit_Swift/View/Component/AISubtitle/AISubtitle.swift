//
//  AISubtitle.swift
//  Pods
//
//  Created by vincepzhang on 2025/4/22.
//

import RTCRoomEngine

#if canImport(TXLiteAVSDK_TRTC)
import TXLiteAVSDK_TRTC
#elseif canImport(TXLiteAVSDK_Professional)
import TXLiteAVSDK_Professional
#endif

class AISubtitle: UIView {
    private let aiMessageType: Int = 10000
    private let showDuration: Double = 8
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        tableView.layer.cornerRadius = 12
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = true
        tableView.bounces = true
        tableView.alwaysBounceVertical = true
        tableView.isScrollEnabled = true
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    private var translationInfo:[TranslationInfo] = []
    private var hideTimer: Timer?
    private var isUserScrolling: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        TUICallEngine.createInstance().getTRTCCloudInstance().addDelegate(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.isHidden = true
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: "SubtitleCell")
    }
    
    private func updateSubtitle() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isHidden = false
            self.tableView.reloadData()
            
            if !self.translationInfo.isEmpty && !self.isUserScrolling {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let lastIndex = self.translationInfo.count - 1
                    let indexPath = IndexPath(row: lastIndex, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
            
            self.hideTimer?.invalidate()
            self.hideTimer = Timer.scheduledTimer(withTimeInterval: showDuration, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                self.isHidden = true
            }
        }
    }
    
    private func getUser(userId: String) -> User? {
        if userId == CallManager.shared.userState.selfUser.id.value {
            return CallManager.shared.userState.selfUser
        }
        
        for user in CallManager.shared.userState.remoteUserList.value {
            if userId == user.id.value {
                return user
            }
        }
        return nil
    }
    
    deinit {
        hideTimer?.invalidate()
    }
    
    class TranslationInfo {
        var roundId: String = ""
        var sender: String = ""
        var text: String = ""
        var translation: [String: String] = [:]
    }
}

// MARK: - UITableViewDataSource
extension AISubtitle: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return translationInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubtitleCell", for: indexPath) as! SubtitleCell
        let message = translationInfo[indexPath.row]
        
        guard let user = getUser(userId: message.sender) else { return cell }
        let displayName = UserManager.getUserDisplayName(user: user)
        
        cell.configure(with: message, displayName: displayName)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AISubtitle: UITableViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isUserScrolling = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.isUserScrolling = false
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isUserScrolling = false
        }
    }
}

extension AISubtitle: TRTCCloudDelegate {
    func onRecvCustomCmdMsgUserId(_ userId: String, cmdID: Int, seq: UInt32, message: Data) {
        if let string = String(data: message, encoding: .utf8) {
            
            if let data = string.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let type = json["type"] as? Int, type == aiMessageType {
                
                let sender: String = json["sender"] as? String ?? ""
                let payload = json["payload"] as? [String: Any] ?? [:]
                let text = payload["text"] as? String ?? ""
                let translationText = payload["translation_text"] as? String ?? ""
                let roundId = payload["roundid"] as? String ?? ""
                let translation_language = payload["translation_language"] as? String ?? ""

                
                if let index = translationInfo.firstIndex(where: { $0.roundId == roundId }) {
                    translationInfo[index].sender = sender.contains(AI_TRANSLATION_ROBOT) ? translationInfo[index].sender : sender
                    translationInfo[index].text = text.isEmpty ? translationInfo[index].text : text
                    
                    translationInfo[index].translation[translation_language] = translationText.isEmpty ? translationInfo[index].translation[translation_language] : translationText
                } else {
                    let franslationInfo = TranslationInfo()
                    franslationInfo.roundId = roundId
                    franslationInfo.sender = sender.contains(AI_TRANSLATION_ROBOT) ? "" : sender
                    franslationInfo.text = text
                    franslationInfo.translation[translation_language] = translationText

                    translationInfo.append(franslationInfo)
                }
                updateSubtitle()
            }
        }
    }
}

// MARK: - SubtitleCell
class SubtitleCell: UITableViewCell {
    private let languageOrder = ["zh", "en", "es", "pt", "fr", "de", "ru", "ar", "ja", "ko", "vi", "ms", "id", "it", "th"]
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        addSubview(contentLabel)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            contentLabel.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            contentLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2)
        ])
        
        isUserInteractionEnabled = true
    }
    
    func configure(with message: AISubtitle.TranslationInfo, displayName: String) {
        var formattedText = ""
        
        if !message.text.isEmpty {
            formattedText += "\(displayName):\n\(message.text)\n"
        }
        

        for language in languageOrder {
            if let translation = message.translation[language], !translation.isEmpty {
                formattedText += "[\(language)]: \(translation)\n"
            }
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        paragraphStyle.paragraphSpacing = 0
        
        let attributedText = NSMutableAttributedString(string: formattedText, attributes: [
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14)
        ])
        
        if let rangeOfColon = formattedText.firstIndex(of: ":") {
            let nameRange = NSRange(formattedText.startIndex..<rangeOfColon, in: formattedText)
            attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 14), range: nameRange)
            attributedText.addAttribute(.foregroundColor, value: UIColor(red: 0.85, green: 0.8, blue: 0.4, alpha: 1.0), range: nameRange)
        }
        
        contentLabel.attributedText = attributedText
    }
}

