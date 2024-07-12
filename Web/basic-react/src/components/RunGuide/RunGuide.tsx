import { Button, Image, Typography } from "antd";
import RunGuideSrc from '../../assets/runGuide/run-guide.svg'
import { useLanguage } from "../../hooks";

const { Text } = Typography;

export default function RunGuide() {
  const { t } = useLanguage();
  return (
    <>
      <Button>
        <Image src={RunGuideSrc} preview={false} />
        <Text> { t('Onboard Guide') } </Text>
      </Button>
    </>
  )
}
