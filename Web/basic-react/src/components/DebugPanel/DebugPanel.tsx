import React, { useContext, useEffect, useState } from "react";
import { Input, Button, MessagePlugin } from "tdesign-react";
import { DesktopIcon, LockOnIcon } from "tdesign-icons-react";
import { TUICallKitServer } from "@tencentcloud/call-uikit-react";
import { useTranslation } from "react-i18next";
import TIM from "@tencentcloud/chat";
import * as GenerateTestUserSig from "../../../public/debug/GenerateTestUserSig-es.js";
import StoreContext from "../../store/context";

export default function BaseForm() {
  const { t } = useTranslation();
  const [SDKAppID, setSDKAppID] = useState();
  const [SecretKey, setSecretKey] = useState("");
  const [userId, setUserId] = useState("");
  const { upDataUserId, upDataLoginInfo } = useContext(StoreContext);
  useEffect(() => {
    if (getUrlParam("SDKAppID")) {
      setSDKAppID(parseInt(getUrlParam("SDKAppID") as string));
      setSecretKey(getUrlParam("SecretKey") || "");
    }
  }, []);

  const getUrlParam = (key: string): string => {
    const url = decodeURI(window.location.href.replace(/^[^?]*\?/, ""));
    const regexp = new RegExp(`(^|&)${key}=([^&#]*)(&|$|)`, "i");
    const paramMatch = url.match(regexp);
    return paramMatch ? paramMatch[2] : "";
  };

  const onSubmit = async () => {
    if (userId) {
      try {
        await login(userId);
        upDataUserId(userId);
        MessagePlugin.success("Login successful");
      } catch (error) {
        MessagePlugin.error("Login failed");
      }
    } else {
      MessagePlugin.error("Fill in relevant information");
    }
  };

  const login = async (userId: any) => {
    const SDKAppID: any = GenerateTestUserSig.SDKAPPID || getUrlParam("SDKAppID");
    const SecretKey: any = GenerateTestUserSig.SECRETKEY || getUrlParam("SecretKey") || "";
    
    const { userSig } = GenerateTestUserSig.genTestUserSig({
      userID: userId,
      SDKAppID,
      SecretKey,
    });
    const tim = TIM.create({ SDKAppID });
    await TUICallKitServer.init({
      userID: userId,
      userSig,
      SDKAppID,
      tim,
    });
    upDataLoginInfo({ SDKAppID: Number(SDKAppID), SecretKey: SecretKey, tim });
  };

  return (
    <>
      <div style={{ width: 350 }}>
        <h4> {t("Debug Panel")}</h4>
        <Input
          value={userId}
          prefixIcon={<LockOnIcon />}
          clearable={true}
          onChange={(value) => {
            setUserId(value);
          }}
          placeholder={t("Please enter userId")}
        />
        <Button onClick={onSubmit} theme="primary" type="submit" block>
          {t("login")}
        </Button>
      </div>
    </>
  );
}
