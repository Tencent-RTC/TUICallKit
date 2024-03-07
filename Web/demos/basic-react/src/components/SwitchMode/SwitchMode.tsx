import React, { useContext, useState } from "react";
import { Radio, Button, Dropdown } from "tdesign-react";
import { Icon } from "tdesign-icons-react";
import { useTranslation } from "react-i18next";
import StoreContext from "../../store/context";
import "./SwitchMode.less";

export default function SingleSelect() {
  const { t } = useTranslation();
  const [langTitle, setLangTitle] = useState("language");
  const context = useContext(StoreContext);
  const handleChange = (value) => {
    context.upDataCallType(value);
  };
  const options = [
    {
      content: "简体中文",
      lang: "zh-cn",
      value: 1,
    },
    {
      content: "English",
      lang: "en",
      value: 2,
    },
    {
      content: "日本語",
      lang: "ja_JP",
      value: 3,
    },
  ];
  const clickHandler = (data: any) => {
    context.setLanguage(data);
    setLangTitle(data.content);
  };

  return (
    <>
      <Radio.Group
        variant="primary-filled"
        defaultValue={2}
        onChange={handleChange}
      >
        <Radio.Button value={2}>{t("video-call")}</Radio.Button>
        <Radio.Button value={1}>{t("audio-call")}</Radio.Button>
      </Radio.Group>
      <div className="switch-lang">
        <Dropdown options={options} onClick={clickHandler}>
          <Button
            variant="text"
            suffix={<Icon name="chevron-down" size="16" />}
          >
            {langTitle}
          </Button>
        </Dropdown>
      </div>
    </>
  );
}
