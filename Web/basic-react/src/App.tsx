import React, { useMemo, useState } from "react";
import "./App.css";
import { TUICallKit, TUICallKitServer, TUIGlobal } from "@tencentcloud/call-uikit-react";
import "tdesign-react/es/style/index.css";
import SwitchMode from "./components/SwitchMode/SwitchMode";
import DebugPanel from "./components/DebugPanel/DebugPanel";
import ResultList from "./components/ResultList/ResultList";
import SearchBox from "./components/SearchBox/SearchBox";
import QRCodeContainer  from "./components/QRCodeContainer/QRCodeContainer";
import StoreContext from "./store/context";
import { useTranslation } from "react-i18next";


function App() {
  const { i18n } = useTranslation();
  const [useId, setUseId] = useState("");
  const [searchResult, setSearchResult] = useState([]);
  const [callType, setCallType] = useState(2);
  const [isCalling, setCallStatus] = useState(false);
  const [loginInfo, setLoginInfo] = useState({})
  const upDataUserId = (value: any) => {
    setUseId(value);
  };

  const upDataCallType = (value: any) => {
    setCallType(value);
  };

  const upDataSearchResult = (value: any) => {
    setSearchResult(value);
  };

  const upDataLoginInfo = (value: any) =>{
    setLoginInfo(value)
  } 

  const handleBeforeCalling = () => {
    setCallStatus(true)
  };

  const handleAfterCalling = () => {
    setCallStatus(false)
  };

  const setLanguage = (value:any) => {
    TUICallKitServer.setLanguage(value.lang)
    let lang = value.lang;
    if (value.lang === 'zh-cn') {
      lang = 'zh';
    } else if (value.lang === 'ja_JP') {
      lang = 'jp';
    }
    i18n.changeLanguage(lang);
  }

  const callkitStyle = useMemo(() => {
    if (TUIGlobal.isPC) {
      return { width: '960px', height: '630px' };
    }

    return { width: '100%', height: window.innerHeight };
  }, [TUIGlobal.isPC]);

  return (
    <>
      <TUICallKit 
        className='TUICallKit-body' 
        style={callkitStyle} 
        beforeCalling={handleBeforeCalling} 
        afterCalling={handleAfterCalling} 
        allowedMinimized={true}
      />
      {
        <StoreContext.Provider
          value={{
            useId,
            callType,
            searchResult,
            loginInfo,
            upDataCallType,
            upDataUserId,
            upDataSearchResult,
            setLanguage,
            upDataLoginInfo
          }}
        >
          <div className="wrapper">
            { useId && ( <>
              <div className="switch">
                <SwitchMode></SwitchMode>
              </div>
              {(useId && !isCalling && TUIGlobal.isPC) && <QRCodeContainer></QRCodeContainer>}
              <div className="call-kit-container">
                <div className="search-window">
                  <SearchBox></SearchBox>
                </div>
                <div className="result-list">
                  <ResultList></ResultList>
                </div>
              </div> 
            </> ) }
          
            {!useId && (
              <div id="debug">
                <DebugPanel></DebugPanel>
              </div>
            )}
          </div>
        </StoreContext.Provider>
      }
    </>
  );
}

export default App;
