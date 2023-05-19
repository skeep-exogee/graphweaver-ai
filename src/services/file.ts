import fs from "fs";
const dir = "./output";

export const createOutput = () => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir);
  }
};

export const writeFile = (fileName: string, contents: string) => {
  if (!fileName.search(".ts")) fileName = fileName + "/ts";

  fs.writeFileSync(`${dir}/${fileName}`, contents, {
    encoding: "utf8",
    flag: "w",
  });
};
