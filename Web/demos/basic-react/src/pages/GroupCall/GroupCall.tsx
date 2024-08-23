import { useEffect, useContext } from 'react';
import { useNavigate } from 'react-router-dom';
import { UserInfoContext } from '../../context';
import { isH5 } from "../../utils";
import GroupCallH5 from './H5/GroupCall';
import GroupCallPC from './PC/GroupCall';

export default function GroupCall() {
  const { userInfo, setUserInfo } = useContext(UserInfoContext);
  const navigate = useNavigate();
  
  useEffect(() => {
    if (!userInfo?.isLogin) {
      navigate('/login')
    }
    setUserInfo({
      ...userInfo,
      currentPage: 'groupCall',
    })
  }, []);

  return (
    <>
      {
        isH5 
          ? <GroupCallH5 />
          : <GroupCallPC />
      }
    </>
  )
}
