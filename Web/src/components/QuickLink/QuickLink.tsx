import { isH5 } from "../../utils";
import QuickLinkH5 from "./H5/QuickLink";
import QuickLinkPC from "./PC/QuickLink";

export default function QuickLink() {
  return (
    <>
      {
        isH5
        ? <QuickLinkH5 />
        : <QuickLinkPC />
      }
    </>
  )
}
