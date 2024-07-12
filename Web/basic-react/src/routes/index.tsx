import { createHashRouter } from "react-router-dom";
import Login from '../pages/Login/Login';
import Home from '../pages/Home/Home';
import Call from '../pages/Call/Call';
import GroupCall from '../pages/GroupCall/GroupCall';
import Error from '../pages/Error/Error'

const router = createHashRouter([
  {
    path: '/',
    element: <Login />,
    errorElement: <Error />,
  },
  {
    path: '/login',
    element: <Login />,
    errorElement: <Error />,
  },
  {
    path: '/home',
    element: <Home />,
    errorElement: <Error />,
  },
  {
    path: '/call',
    element: <Call />,
    errorElement: <Error />,
  },
  {
    path: '/groupCall',
    element: <GroupCall />,
    errorElement: <Error />,
  }
]);

export default router;
