import { useEffect, useContext } from 'react';
import { useNavigate } from 'react-router-dom';
import { UserInfoContext } from '../../context';
import { isH5 } from '../../utils';
import HomePC from './PC/Home';
import HomeH5 from './H5/Home';

export default function Home() {
  const navigate = useNavigate()
  const { userInfo, setUserInfo } = useContext(UserInfoContext);

  useEffect(() => {
    if (!userInfo.isLogin) {
      navigate('/login');
    }
    setUserInfo({
      ...userInfo,
      currentPage: 'home',
    })
  }, []);
  
  return (
    <>
      {
        isH5 ? <HomeH5 /> : <HomePC />
      }
    </>
  )
}
