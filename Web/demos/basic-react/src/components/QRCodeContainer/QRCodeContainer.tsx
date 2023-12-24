import React, { useEffect, useState, useContext } from "react";
import QRCode from "qrcode";
import QRCodeBox from "../../assets/QRCodeBox.png";
import { useTranslation } from "react-i18next";
import StoreContext from "../../store/context";
import "./QRCodeContainer.less";
const commonUrl = 'https://web.sdk.qcloud.com/component/TUICallKit/demos/basic-react/index.html'

export default function QRCodeContainer() {
  const { t } = useTranslation();
  const [QRCodeUrl, setQRCodeUrl] = useState("");
  const { loginInfo } = useContext(StoreContext);
  useEffect(() => {
    getQrCodeUrl();
  }, []);
  const getQrCodeUrl = async () => {
    const qrCodeUrl =
      `${commonUrl}?SDKAppID=${loginInfo.SDKAppID}&SecretKey=${loginInfo.SecretKey}`;
    try {
      const imgData = await QRCode.toDataURL(qrCodeUrl, {
        errorCorrectionLevel: "M",
        type: "image/jpeg",
        margin: 0,
      });
      if (imgData) {
        setQRCodeUrl(imgData);
      } else {
        alert("failed to resolve qrCode");
      }
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <div className="call-kit-QRcode">
      <div className="call-kit-QRcode-text">
        {t("Wechat scan right QR code")} <br />
        {t("Use-phone-and-computer")}
      </div>
      <div className="call-kit-QRcode-image">
        <img className="QRCodeBox" src={QRCodeBox} />
        <img className="QRCode" src={QRCodeUrl} />
      </div>
    </div>
  );
}
