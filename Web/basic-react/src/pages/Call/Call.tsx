import { useEffect, useContext } from 'react';
import { useNavigate } from 'react-router-dom';
import { UserInfoContext } from '../../context';
import { isH5 } from '../../utils';
import CallPC from './PC/Call';
import CallH5 from './H5/Call';

export default function Call() {

  const navigate = useNavigate()
  const { userInfo, setUserInfo } = useContext(UserInfoContext);

  useEffect(() => {
    setUserInfo({
      ...userInfo,
      currentPage: 'call',
    })
    if (!userInfo?.isLogin) {
      navigate('/login');
    }
  }, []);

  return (
    <>
      {
        isH5 ? <CallH5 /> : <CallPC />
      }
    </>
  )
}