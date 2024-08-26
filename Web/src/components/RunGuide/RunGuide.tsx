import { useState, useMemo } from "react";
import { Button, Image, Typography } from "antd";
import RunGuideSrc from '../../assets/runGuide/run-guide.svg'
import { useLanguage } from "../../hooks";
import RunGuidePanel from "./RunGuidePanel/RunGuidePanel";

const { Text } = Typography;

export default function RunGuide() {
  const { t } = useLanguage();
  const [isShowPanel, setIsShowPanel] = useState(false);
  const openRunGuidePanel = () => {
    setIsShowPanel(!isShowPanel);
  }
  const operateRunGuidePanel = useMemo(() => {
    return {
      isShowPanel,
      setIsShowPanel,
    }
  }, []);

  return (
    <>
      <Button className="header-card-pc" onClick={openRunGuidePanel}>
        <Image src={RunGuideSrc} preview={false} />
        <Text className="header-card-text"> { t('Onboard Guide') } </Text>
      </Button>
      { isShowPanel && <RunGuidePanel operateRunGuidePanel={operateRunGuidePanel} /> }
    </>
  )
}
