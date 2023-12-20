import React, { useState, useContext } from "react";
import { List, Space, Link, Button, MessagePlugin } from "tdesign-react";
import StoreContext from "../../store/context";
import { TUICallKitServer } from "@tencentcloud/call-uikit-react";
import { useTranslation } from "react-i18next";
import "./ResultList.less";
const { ListItem, ListItemMeta } = List;

export default function BasicList() {
  const { t } = useTranslation();
  const { searchResult, upDataSearchResult, callType, useId } =
    useContext(StoreContext);
  const handleClick = (item:any) => {
    const filteredArr = searchResult.filter((res:any) => res !== item);
    upDataSearchResult(filteredArr);
  };
  const startCall = async () => {
    if (!useId) {
      MessagePlugin.error(t("not-login"));
      return;
    }
    if (searchResult.length === 1) {
      await TUICallKitServer.call({ userID: searchResult[0], type: callType });
    } else {
      await TUICallKitServer.groupCall({
        userIDList: searchResult,
        type: callType,
        // groupID: "@TGS#24SG4XNNV",
        // groupID: '@TGS#2NOQD7SNK', // pop1-pop7
        groupID: '@TGS#2TOJAOTNA', // jony1-jony9
      });
    }
  };

  const renderItem = () => {
    return searchResult.map((item, index) => {
      return (
        <ListItem
          key={index}
          action={
            <Space>
              <Link
                onClick={() => {
                  handleClick(item);
                }}
                theme="primary"
                hover="color"
              >
                {t("delete")}
              </Link>
            </Space>
          }
        >
          <ListItemMeta title={item} />
        </ListItem>
      );
    });
  };
  return (
    <>
      <Space direction="vertical" style={{ width: "100%" }}>
        <List>{renderItem()}</List>
      </Space>
      {searchResult.length > 0 && (
        <Button
          onClick={startCall}
          className="call-btn"
          shape="rectangle"
          size="medium"
          type="button"
          variant="base"
          theme="success"
        >
          {t("call")}
        </Button>
      )}
    </>
  );
}
