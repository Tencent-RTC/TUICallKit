import { IRenderVolumeBarProps, IVolumeArrItem } from '../../../interface/index.ts';
import './VolumeBar.css';

export default function VolumeBar(props: IRenderVolumeBarProps) {
  const { volume } = props;
  const volumeArr = new Array(volume).fill(0);
  const arr = new Array(20-volume).fill(0);
  
  return (
    <>
      {
        volumeArr.map((...res: IVolumeArrItem) => (
          <div className='volume-bar-fill' key={res[1]} />
        ))
      }
      {
        arr.map((...res: IVolumeArrItem) => (
          <div className='volume-bar' key={res[1]} />
        ))
      }
    </>
  )
}
