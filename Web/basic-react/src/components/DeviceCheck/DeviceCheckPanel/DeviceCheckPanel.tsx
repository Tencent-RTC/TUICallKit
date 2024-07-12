import { useEffect, useRef } from 'react';
import { Flex, Image, Select, Checkbox, Typography } from "antd";
import { DEVICE_TYPE, IDeviceCheckPanelProps } from '../../../interface/index.ts';
import { useDevice, useLanguage } from '../../../hooks/index.ts';
import VolumeBar from '../VolumeBar/VolumeBar.tsx';
import testAudioEn from '../../../assets/deviceCheck/test-audio-en.mp3';
import testAudioZh from '../../../assets/deviceCheck/test-audio-zh.mp3';
import ChaSvg from '../../../assets/pages/cha.svg';
import './DeviceCheckPanel.css';

const { Text } = Typography;

export default function DeviceCheckPanel(props: IDeviceCheckPanelProps) {
  const { cameraList, micList, speakerList, volume, startLocalPreview, updateLocalPreview, updateCurrentDevice } = useDevice();
  const { t, language } = useLanguage();
  const renderRef = useRef(true);
  const { setIsShowPanel } = props.operateDevicePanel;

  useEffect(() => {
    if (renderRef.current) {
      renderRef.current = false;
      return;
    }
    startLocalPreview('video-bg');
    return () => {
    }
  }, []);

  const updateCameraDevice = async (value: string) => {
    await updateCurrentDevice(DEVICE_TYPE.CAMERA, value);
  }
  const updateMicDevice = async (value: string) => {
    await updateCurrentDevice(DEVICE_TYPE.MIC, value);
  }
  const updateSpeakerDevice = async (value: string) => { 
    await updateCurrentDevice(DEVICE_TYPE.SPEAKER, value);
  }

  const closePanel = () => {
    setIsShowPanel(false);
  }

  return (
    <> 
      <Flex className='device-check-card' vertical={true}>
        <Flex justify='space-between' align='center'>
          <Text className='device-check-title'> {t('Device Detection')} </Text>
          <Image src={ChaSvg} width={13} preview={false} onClick={closePanel} style={{cursor: 'pointer'}} />
        </Flex>
        <Flex justify='space-between' style={{marginTop: '20px'}}>
          <Text className='device-sub-title'> {t('Camera')} </Text>
          <Flex vertical={true}>
            <Select
              defaultValue={cameraList[0]?.value}
              key={cameraList[0]?.value}
              onChange={updateCameraDevice}
              options={cameraList}
            />
            <div className='video-bg'></div>
            <Checkbox onChange={(event) => updateLocalPreview(event.target.checked)}> {t('Mirror')} </Checkbox>
          </Flex>
        </Flex>
        <Flex justify='space-between' className='device-check-card-margin'>
          <Text className='device-sub-title'> {t('Microphone')} </Text>
          <Flex vertical={true} style={{width: '360px'}}>
            <Select
              defaultValue={micList[0]?.label}
              key={micList[0]?.label}
              onChange={updateMicDevice}
              options={micList}
            />
            <Text className='device-tip'> {t('Please adjust the device volume and say "hello" into the microphone to test it~')} </Text>
            <Flex align='center' style={{marginTop: '10px'}}>
              <Text> {t('Output')} </Text>
              <Flex align='center' justify='space-evenly' className='volume-box'>
                <VolumeBar volume={volume} />
              </Flex>
            </Flex>
          </Flex>
        </Flex>
        <Flex justify='space-between' className='device-check-card-margin'>
          <Text className='device-sub-title'> {t('Speaker')} </Text>
          <Flex vertical={true} style={{width: '360px'}}>
            <Select
              defaultValue={speakerList[0]?.label}
              key={speakerList[0]?.label}
              onChange={updateSpeakerDevice}
              options={speakerList}
            />
            <Text className='device-tip'> {t('Please adjust the device volume and click to play the audio below to test it~')} </Text>
            <Flex vertical={true} style={{marginTop: '10px'}}>
              <Flex align='center'>
                <Text> {t('Audio')} </Text>
                {
                  language.includes('zh') 
                    ? <audio className='audio-play' src={testAudioZh} controls />
                    : <audio className='audio-play' src={testAudioEn} controls />
                }
              </Flex>
            </Flex>
          </Flex>
        </Flex>
      </Flex>
    </>
  )
}


