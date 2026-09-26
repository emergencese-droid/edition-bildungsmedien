export interface Resource {
  nodekey: string;
  source: string;
  title: string;
  type: string;
  uri: string;
  metadata: Record<string, unknown>;
}

export interface ResourceProvider {
  providerName: string;

  search(query: string): Promise<Resource[]>;

  get(id: string): Promise<Resource | null>;

  save(resource: Resource): Promise<void>;

  delete(id: string): Promise<void>;
}
