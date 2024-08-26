import { Empty, Typography } from 'antd';

export default function Error() {
  const { Link} = Typography;

  return (
    <Empty 
      description={
        <>
          <Link href="https://trtc.io/document/50989"> Click to visit Call Docs</Link>
        </>
      }
    />
  )
}