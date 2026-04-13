import React from 'react';
import { useLanguage } from '../../hooks';
import './ConfigCheckTips.css';

const ConfigCheckTips: React.FC = () => {
  const { t } = useLanguage();

  const tips = [
    'config tip 1',
    'config tip 2', 
    'config tip 3',
    'config tip 4',
    'config tip 5'
  ];

  return (
    <div className="config-check-tips">
      <div className="tips-content">
        <p className="tips-subtitle">{t('Please check the following configuration')}:</p>
        <div className="tips-list">
          {tips.map((tip, index) => (
            <div className="tip-item" key={index}>
              <span className="tip-number">{index + 1}.</span>
              {index === 1 ? (
                <span className="tip-text">
                  {t('config tip 2 prefix')}
                  <a href="https://cloud.tencent.com/document/product/647/104662" target="_blank" rel="noopener noreferrer" className="tip-link">
                    {t('config tip 2 link')}
                  </a>
                  {t('config tip 2 suffix')}
                </span>
              ) : (
                <span className="tip-text">{t(tip)}</span>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default ConfigCheckTips;