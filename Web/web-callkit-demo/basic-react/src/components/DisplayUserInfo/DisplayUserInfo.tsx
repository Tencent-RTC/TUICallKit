import { useContext } from 'react';
import { Typography, Flex } from 'antd';
import { UserInfoContext } from '../../context';
import './DisplayUserInfo.css';

const { Paragraph } = Typography;

export default function DisplayUserInfo() {
  const { userInfo } = useContext(UserInfoContext);

  return (
    userInfo.isLogin && (
      <>
        <Flex align='center' className='user-id-text'>
          userID: 
          <Paragraph
            className='user-id'
            ellipsis={true}
            copyable
          >
            {userInfo.userID}
          </Paragraph>
        </Flex>
      </>
    )
  )
}
