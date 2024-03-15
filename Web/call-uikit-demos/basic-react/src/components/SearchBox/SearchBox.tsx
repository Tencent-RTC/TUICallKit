import React, { useState, useContext } from "react";
import { MessagePlugin, Button, Space } from "tdesign-react";
import StoreContext from "../../store/context";
import { useTranslation } from "react-i18next";
import "./SearchBox.less";

export default function SearchBox() {
  const { t } = useTranslation();
  const [searchUserId, setUseId] = useState("");
  const { upDataSearchResult, searchResult, callType, useId } =
    useContext(StoreContext);
  const HandleChange = (e: any) => {
    setUseId(e.target.value);
  };

  const searchUser = () => {
    if (!searchUserId) {
      MessagePlugin.error("Enter UserId");
      return;
    }
    upDataSearchResult([...searchResult, searchUserId]);
    setUseId("");
  };

  return (
    <>
      <div className="search-title">
        <span className="title">{callType === 1 ? t("audio-call") : t("video-call")}</span>
        {useId && (
          <span className="user-id">
            {t("userId")}:{useId}
          </span>
        )}
      </div>
      <input
        className="search-input"
        value={searchUserId}
        onChange={HandleChange}
      />
      <Space direction="vertical" style={{ width: "100%" }}>
        <Button onClick={searchUser} block variant="base">
          {t("Add to call list")}
        </Button>
      </Space>
      {useId && <div className="search-results-PromptText">
        <span className="PromptText">{t("warn")}</span> <br />
        {t("disclose it at will")}
      </div>}
    </>
  );
}
