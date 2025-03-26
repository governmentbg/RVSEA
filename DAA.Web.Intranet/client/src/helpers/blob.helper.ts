/* eslint-disable @typescript-eslint/no-explicit-any */
export const base64ToBlob = (
  base64: any,
  mimetype: string,
  slicesize: number | null = null
) => {
  if (!window.atob || !window.Uint8Array) {
    // The current browser doesn't have the atob function. Cannot continue
    return null;
  }
  mimetype = mimetype || "";

  slicesize = slicesize || 512;
  const bytechars = atob(base64); //decode base64
  const bytearrays = [];

  for (let offset = 0; offset < bytechars.length; offset += slicesize) {
    //slice the byte array
    const slice = bytechars.slice(offset, offset + slicesize);
    const bytenums = new Array(slice.length);
    //process the sliced chunk
    for (let i = 0; i < slice.length; i++) {
      bytenums[i] = slice.charCodeAt(i);
    }
    const bytearray = new Uint8Array(bytenums);
    bytearrays[bytearrays.length] = bytearray;
  }
  return new Blob(bytearrays, { type: mimetype });
};
