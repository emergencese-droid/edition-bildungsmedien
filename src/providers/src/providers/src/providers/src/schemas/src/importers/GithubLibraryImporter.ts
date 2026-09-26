import { Octokit } from "octokit";

export class GithubLibraryImporter {

  private octokit: Octokit;

  constructor(token: string) {
    this.octokit = new Octokit({
      auth: token
    });
  }

  async importRepository(
    owner: string,
    repo: string
  ) {

    const response =
      await this.octokit.rest.repos.get({
        owner,
        repo
      });

    return response.data;
  }
}
