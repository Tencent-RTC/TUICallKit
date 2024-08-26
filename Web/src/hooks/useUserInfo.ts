import { inject } from "vue";
import { UserInfoContextKey, IUserInfoContext, UserInfoContextDefaultValue } from "../context";

export default function useUserInfo() {
  return inject<IUserInfoContext>(UserInfoContextKey) || UserInfoContextDefaultValue;
}