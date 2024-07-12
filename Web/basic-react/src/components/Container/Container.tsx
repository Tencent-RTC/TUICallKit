import { ICardProps } from '../../interface/index';
import DisplayUserInfo from './DisplayUserInfo/DisplayUserInfo';
import Return from './Return/Return';
import './Container.css';

export default function Container(props: ICardProps) {
  const {
    title,
    body,
    className,
  } = props;

  return (
    <>
    <div className='card'>
      <div className='card-title'>
        {title}
        <Return />
        <DisplayUserInfo />
      </div>
      <div className={`card-content ${className}`}>
        {body}
      </div>
    </div>
    </>
  )
}
