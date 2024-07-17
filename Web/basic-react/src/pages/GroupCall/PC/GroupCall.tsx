import { useContext, useState } from 'react';
import { useLocation } from 'react-router-dom';
import { Typography, Image, Flex, Button, Input, message } from 'antd';
import { TUICallKitServer, TUICallType } from '@tencentcloud/call-uikit-react';
import Chat from "@tencentcloud/chat";
import { UserInfoContext } from '../../../context';
import { useLanguage, useAegis } from '../../../hooks';
import { getUrl, checkUserID } from '../../../utils';
import { IMemberList } from '../../../interface/index';
import Container from '../../../components/Container/Container';
import ShareSvg from '../../../assets/pages/share.svg';
import ChaSvg from '../../../assets/pages/cha.svg';
import './GroupCall.css';

const { Text, Link } = Typography;

export default function GroupCall() {
  const { state } = useLocation();
  const { userInfo, setUserInfo } = useContext(UserInfoContext);
  const { t } = useLanguage();
  const [groupCallMember, setGroupCallMember] = useState<string[]>([]);
  const [inputUserID, setInputUserID] = useState('');
  const [messageApi, contextHolder] = message.useMessage();
  const { reportEvent, reportError } = useAegis();

  const createGroupID = async () => {
    reportEvent({ apiName: 'createGroupID.start' });
    const chat = Chat.create({ SDKAppID: userInfo?.SDKAppID });
    const memberList: IMemberList[] = groupCallMember.map(userID => ({ userID }));
    
    const res = await chat.createGroup({
      type: Chat.TYPES.GRP_PUBLIC,
      name: 'WebSDK',
      memberList
    });
    return res.data.group.groupID;
  }
  
  const handleGroupCall = async () => {
    reportEvent({ apiName: 'groupCall.start' });
    if (groupCallMember.length < 1) {
      messageApi.info(t('Please add at least one member'));
      return;
    }
    setUserInfo({
      ...userInfo,
      isCall: true,
    });
    try {
      const groupID = await createGroupID();
      await TUICallKitServer.groupCall({
        userIDList: groupCallMember, 
        groupID,
        type: state?.callType === 'video' ? TUICallType.VIDEO_CALL : TUICallType.AUDIO_CALL,
      })
      reportEvent({ apiName: 'groupCall.success'});
    } catch (error) {
      console.error('groupCall error', error);
      setUserInfo({
        ...userInfo,
        isCall: true,
      });
      reportError({
        apiName: 'groupCall.error',
        content: JSON.stringify(error),
      });
    }
  }

  function renderGroupCallPanel() {

    const openNewWindow = () => {
      window.open(getUrl());
    }

    const handleInputChange = (event: any) => {
      if (!checkUserID(event?.target?.value?.replace(/\s/g, ''))) {
        messageApi.info(t('Please input the correct userID'));
      }
      setInputUserID(event?.target?.value?.replace(/\s/g, ''))
    }
    const addGroupCallMember = () => {
      if (!inputUserID) return;
      if (!checkUserID(inputUserID)) {
        messageApi.info(t('Please input the correct userID'));
        return;
      }
      if (groupCallMember.includes(inputUserID)) {
        messageApi.info(t('The user already exists'));
        return;
      }
      if (inputUserID === userInfo?.userID) {
        messageApi.info(t("You can't add yourself"));
        setInputUserID('');
        return;
      }
      if (groupCallMember.length < 8) {
        setGroupCallMember([...groupCallMember, inputUserID]);
      } else {
        messageApi.info(t("The group is full"));
      }
      setInputUserID('');
    }
    const deleteGroupCallUser = (userID: string) => {
      setGroupCallMember(groupCallMember.filter(item => item !== userID));
    }
    return (
      <Flex vertical={true} align='center' className='pc-group-call'>
        <Flex vertical={true}>
          <Link onClick={openNewWindow}>
            {t('Create a New userID')}
            <Image src={ShareSvg} preview={false} />
          </Link>
          <Flex 
            className='group-call-input'
            align='center'
            justify='space-between'
          >
            <Input
              className='pc-call-input'
              placeholder={t('input userID to Add')}
              value={inputUserID}
              onChange={handleInputChange}
              onPressEnter={addGroupCallMember}
            />
            <Button className='group-call-add' onClick={addGroupCallMember} > {t('Add')} </Button>
          </Flex>
        </Flex>
        <Flex vertical={true} style={{width: '100%'}}>
          <Text className='group-call-text'> 
            {t('Group Members')}
            ({(groupCallMember.length + 1)}{t('people')}
            / 9{t('people')})
          </Text>
          <Flex wrap>
            <Text className='group-call-list'>
              <Text ellipsis={true} style={{color: "#727A8A"}} > {userInfo?.userID} </Text>
              <Text style={{color: "#727A8A"}}>({t('You')})</Text>
            </Text>
            {
              groupCallMember.map((item) => 
                <Flex className='group-call-list' key={item}>
                  <Text className='group-call-list-text' ellipsis={true} >
                    {item}
                  </Text>
                  <Image
                    style={{cursor: 'pointer'}}
                    src={ChaSvg} 
                    preview={false} 
                    width={12} 
                    onClick={() => deleteGroupCallUser(item)}
                  />
                </Flex>
              )
            }
          </Flex>
        </Flex>
        <Button
          className='pc-group-call-init-btn'
          onClick={handleGroupCall}
        > 
          {t('Initiate Call')} 
        </Button>
      </Flex>
    )
  }

  return (
   <>
      {contextHolder}
      <Container
        body={renderGroupCallPanel()}
      />
   </>
  )
}

