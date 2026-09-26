import { ResourceProvider, Resource } from "./ResourceProvider";

export class GithubProvider implements ResourceProvider {

  providerName = "github";

  async search(query: string): Promise<Resource[]> {
    return [];
  }

  async get(id: string): Promise<Resource | null> {
    return null;
  }

  async save(resource: Resource): Promise<void> {
    console.log(resource);
  }

  async delete(id: string): Promise<void> {
    console.log(id);
  }
}
