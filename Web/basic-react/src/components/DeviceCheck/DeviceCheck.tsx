import { useState, useMemo } from 'react';
import { Button, Image, Typography } from "antd";
import useLanguage from '../../hooks/useLanguage.ts';
import DeviceCheckPanel from './DeviceCheckPanel/DeviceCheckPanel.tsx';
import DeviceCheckIcon from '../../assets/deviceCheck/device-check.svg';

const { Text } = Typography;

export default function DeviceCheck() {
  const { t } = useLanguage();
  const [isShowPanel, setIsShowPanel] = useState(false);
  const openDeviceCheckPanel = () => {
    setIsShowPanel(!isShowPanel);
  }
  const operateDevicePanel = useMemo(() => {
    return {
      isShowPanel,
      setIsShowPanel,
    }
  }, []);

  return (
    <>
      <Button onClick={openDeviceCheckPanel}>
        <Image src={DeviceCheckIcon} preview={false} />
        <Text> {t('Device Detection')} </Text>
      </Button>
      {
        isShowPanel && <DeviceCheckPanel operateDevicePanel={operateDevicePanel} />
      }
    </>
  )
}
