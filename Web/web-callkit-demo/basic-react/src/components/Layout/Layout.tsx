import { isH5 } from '../../utils';
import LayoutPC from './PC/Layout';
import LayoutH5 from './H5/Layout';

interface IPageLayout {
  children: JSX.Element;
}
export default function Layout(props: IPageLayout) {  
  return (
    <>
      {
        isH5 
          ? <LayoutH5> 
              <> {props.children} </> 
            </LayoutH5> 
          : <LayoutPC> 
              <> {props.children} </> 
            </LayoutPC>
      }
    </>
  )
}

