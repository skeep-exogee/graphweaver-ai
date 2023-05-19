import { Octokit } from "octokit";

const octokit = new Octokit();

export const getDataEntities = async () => {
  const { data: example } = await octokit.rest.repos.getContent({
    owner: "exogee-technology",
    repo: "graphweaver",
    path: "src/examples/databases/src/backend/entities/postgresql/user.ts",
  });

  const examplePostgresDataEntity = Buffer.from(
    (example as { content: string }).content,
    "base64"
  ).toString();

  return examplePostgresDataEntity;
};
