import { useContext, useMemo, useState } from "react"
import { useNavigate, useLocation } from 'react-router-dom';
import { Image, Flex, Input, Typography, Button, message } from 'antd';
import { TUICallKitServer, TUICallType } from '@tencentcloud/call-uikit-react';
import Chat from "@tencentcloud/chat";
import { IMemberList } from '../../../interface/index';
import { UserInfoContext } from "../../../context";
import { useLanguage, useAegis } from "../../../hooks";
import { ClassNames, checkUserID, trim } from '../../../utils';
import ReturnH5Svg from '../../../assets/pages/h5-return.svg';
import ChaSvg from '../../../assets/pages/cha.svg';
import './GroupCall.css';

const { Text } = Typography;
export default function GroupCall() {
  const { userInfo, setUserInfo } = useContext(UserInfoContext);
  const navigate = useNavigate();
  const { state } = useLocation();
  const { t } = useLanguage();
  const [groupCallMember, setGroupCallMember] = useState<string[]>([]);
  const [inputUserID, setInputUserID] = useState('');
  const [messageApi, contextHolder] = message.useMessage();
  const { reportEvent} = useAegis();

  const disabledAdd = useMemo(() => groupCallMember.length === 8, [groupCallMember]);

  const goHome = () => {
    navigate('/home');
  }

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
      reportEvent({ apiName: 'groupCall.success' });
    } catch (error) {
      console.error('groupCall error', error);
      setUserInfo({
        ...userInfo,
        isCall: true,
      });
      reportEvent({ apiName: 'groupCall.fail' });
    }
  }

  const handleInputChange = (event: any) => {
    if (!checkUserID(trim(event?.target?.value))) {
      messageApi.info(t('Please input the correct userID'));
    }
    setInputUserID(trim(event?.target?.value));
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
    }
    setInputUserID('');
  }
  const deleteGroupCallUser = (userID: string) => {
    setGroupCallMember(groupCallMember.filter(item => item !== userID));
  }
  const groupCallAddPanel = useMemo(() => (
    ClassNames(['h5-group-call-add-btn', {'disabled-btn': disabledAdd}])
  ), [groupCallMember]);

  return (
    <>
      {contextHolder}
      <Flex className="call-h5-panel" vertical={true}>
        <Flex className="call-h5-bar" align="center">
          <Image src={ReturnH5Svg} width='10px' preview={false} className="h5-call-img" onClick={goHome} />
          <span className="h5-call-text">  {t('Group Call')} </span>
        </Flex>
        <div className="h5-group-call-panel">
          <Flex justify="space-between" align="center" style={{margin: '0 0 17px 0'}}>
            <span> {t('Group Members')} </span>
            <span> ({(groupCallMember.length + 1)}{t('people')}
            /9{t('people')}) </span>
          </Flex>
          <Flex wrap className="h5-group-call-member-panel">
            <Flex className='h5-group-call-list'>
              <Text ellipsis={true} style={{color: "#727A8A", width: '50px'}} > {userInfo?.userID} </Text>
              <Text style={{color: "#727A8A"}}>({t('You')})</Text>
            </Flex>
            {
              groupCallMember.map((item, index) => 
                <Flex className='h5-group-call-list' key={index}>
                  <Text ellipsis={true} style={{width: '80px'}}> {item} </Text>
                  <Image
                    style={{cursor: 'pointer'}}
                    src={ChaSvg} 
                    preview={false} 
                    width={10}
                    onClick={() => deleteGroupCallUser(item)}
                  />
                </Flex>
              )
            }
          </Flex>
          <Flex className="h5-group-call-add-panel" >
            {
              !disabledAdd
                ? (
                  <Input
                    className="h5-group-call-input"
                    placeholder={t('input userID to Add')}
                    value={inputUserID}
                    onChange={handleInputChange}
                    onPressEnter={addGroupCallMember}
                  />
                )
                : <span style={{color: '#ACB6C5'}}> {t('The group is full')} </span>
            }
            <Button 
              className={groupCallAddPanel} 
              onClick={addGroupCallMember}> {t('Add')} </Button>
          </Flex>
        </div>
        <div className="h5-call-btn" onClick={handleGroupCall}> {t('Initiate Call')} </div>
      </Flex>
    </>
  )
}