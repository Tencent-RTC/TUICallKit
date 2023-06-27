export const BaseRoutes = [
  {
    path: '/',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
  },
  {
    path: '/call',
    name: 'Call',
    component: () => import('@/views/Call.vue'),
    children: [
      {
        path: 'home',
        component: () => import('@/components/HomePanel.vue'),
      },
      {
        path: 'panel/:callType',
        component: () => import('@/components/call/CallPanel/CallPanel.vue'),
      },
    ],
  },
];
