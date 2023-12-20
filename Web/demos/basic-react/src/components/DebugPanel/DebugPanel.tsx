import React, { useContext, useEffect, useState } from "react";
import { Input, Button, MessagePlugin } from "tdesign-react";
import { DesktopIcon, LockOnIcon } from "tdesign-icons-react";
import { TUICallKitServer } from "@tencentcloud/call-uikit-react";
import { useTranslation } from "react-i18next";
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
    if (SDKAppID && SecretKey && userId) {
      try {
        await login(SDKAppID, SecretKey, userId);
        upDataUserId(userId);
        MessagePlugin.success("Login successful");
      } catch (error) {
        MessagePlugin.error("Login failed");
      }
    } else {
      MessagePlugin.error("Fill in relevant information");
    }
  };

  const login = async (SDKAppID: any, SecretKey: any, userId: any) => {
    const { userSig } = GenerateTestUserSig.genTestUserSig({
      userID: userId,
      SDKAppID: Number(SDKAppID),
      SecretKey: SecretKey,
    });
    await TUICallKitServer.init({
      userID: userId,
      userSig,
      SDKAppID: Number(SDKAppID),
    });
    upDataLoginInfo({ SDKAppID: Number(SDKAppID), SecretKey: SecretKey });
  };

  return (
    <>
      <div style={{ width: 350 }}>
        <h4> {t("Debug Panel")}</h4>
        <Input
          value={SDKAppID}
          clearable={true}
          prefixIcon={<DesktopIcon />}
          onChange={(value) => {
            setSDKAppID(value);
          }}
          placeholder={t("Please enter SDKAppID")}
        />
        <Input
          value={SecretKey}
          prefixIcon={<LockOnIcon />}
          onChange={(value) => {
            setSecretKey(value);
          }}
          clearable={true}
          placeholder={t("Please enter SecretKey")}
        />
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
