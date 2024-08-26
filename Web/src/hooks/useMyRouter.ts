import { useRouter } from 'vue-router';

export default function useMyRouter() {
  const router = useRouter();

  const navigate = (param: string) => {
    router.push(param);
  }

  return {
    navigate,
  }
}
