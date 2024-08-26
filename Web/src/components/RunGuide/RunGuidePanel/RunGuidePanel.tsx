
import { Tree, Flex, Image, Divider } from "antd"
import type { TreeDataNode } from 'antd';
import { useLanguage } from "../../../hooks";
import ChaSrc from '../../../assets/pages/cha.svg';
import GreenRightSrc from '../../../assets/runGuide/green-right.svg';
import './RunGuidePanel.css';


export interface IOperateDevicePanel {
  isShowPanel?: boolean,
  setIsShowPanel: React.Dispatch<boolean>;
}

interface IRunGuidePanelProps {
  operateRunGuidePanel: IOperateDevicePanel;
}

export default function RunGuidePanel(props: IRunGuidePanelProps) {

  const { setIsShowPanel } = props.operateRunGuidePanel;
  const { t } = useLanguage();

  const treeData: TreeDataNode[] = [
    { 
      title: `${t('Create / Log in userID')}`,
      key: 'step1',
    },
    {
      title: `${t('Complete Device Detection')}`,
      key: 'step2',
    },
    {
      title: `${t('Choose Video Call/Voice Call')}`,
      key: 'step3',
    },
    { 
      title: `${t('Initiate One-on-One Call')}`, 
      key: 'step4',
      children: [
        {
          title: `${t('Copy the link of this page to create a new user, or use your phone to scan the QR code')}`,
          key: 'step4-1',
        },
        {
          title: `${t('input the userID and initiate a one-on-one call')}`,
          key: 'step4-2',
        },
      ]
    },
    { 
      title: `${t('Initiate Group Call')}`, 
      key: 'step5',
      children: [
        {
          title: `${t('Copy the link of this page to create multiple users')}`,
          key: 'step5-1',
        },
        {
          title: `${t('Enter the userID and add up to 9 group members')}`,
          key: 'step5-2',
        },
        {
          title: `${t('Initiate Group Call')}`, 
          key: 'step5-3',
        },
      ]
    },
  ]

  const closePanel = () => {
    setIsShowPanel(false);
  }

  return (
    <>
      <Flex className="run-guide-panel" vertical={true}>
        <Flex justify="space-between">
          <span className="header-subCard-title"> {t('Run Demo Guide')} </span>
          <Image style={{cursor: 'pointer'}} src={ChaSrc} width={10} preview={false} onClick={closePanel} />
        </Flex>
        <Divider style={{margin: '16px 0'}} />
        <Tree
          showIcon
          showLine
          switcherIcon={<Image src={GreenRightSrc} preview={false} />}
          defaultExpandAll
          treeData={treeData}
        />
      </Flex>
    </>
  )
}