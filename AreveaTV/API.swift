//  This file was automatically generated and should not be edited.

import AWSAppSync

public struct CreateMULTICREATORSHAREDDATAInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(data: String? = nil, id: String, version: Int? = nil) {
    graphQLMap = ["data": data, "id": id, "version": version]
  }

  public var data: String? {
    get {
      return graphQLMap["data"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "data")
    }
  }

  public var id: String {
    get {
      return graphQLMap["id"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var version: Int? {
    get {
      return graphQLMap["version"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "version")
    }
  }
}

public struct DeleteMULTICREATORSHAREDDATAInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: String) {
    graphQLMap = ["id": id]
  }

  public var id: String {
    get {
      return graphQLMap["id"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct UpdateMULTICREATORSHAREDDATAInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(data: String? = nil, expectedVersion: Int? = nil, id: String) {
    graphQLMap = ["data": data, "expectedVersion": expectedVersion, "id": id]
  }

  public var data: String? {
    get {
      return graphQLMap["data"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "data")
    }
  }

  public var expectedVersion: Int? {
    get {
      return graphQLMap["expectedVersion"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "expectedVersion")
    }
  }

  public var id: String {
    get {
      return graphQLMap["id"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct TableMULTICREATORSHAREDDATAFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: TableStringFilterInput? = nil) {
    graphQLMap = ["id": id]
  }

  public var id: TableStringFilterInput? {
    get {
      return graphQLMap["id"] as! TableStringFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct TableStringFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(beginsWith: String? = nil, between: [String?]? = nil, contains: String? = nil, eq: String? = nil, ge: String? = nil, gt: String? = nil, le: String? = nil, lt: String? = nil, ne: String? = nil, notContains: String? = nil) {
    graphQLMap = ["beginsWith": beginsWith, "between": between, "contains": contains, "eq": eq, "ge": ge, "gt": gt, "le": le, "lt": lt, "ne": ne, "notContains": notContains]
  }

  public var beginsWith: String? {
    get {
      return graphQLMap["beginsWith"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "beginsWith")
    }
  }

  public var between: [String?]? {
    get {
      return graphQLMap["between"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var contains: String? {
    get {
      return graphQLMap["contains"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contains")
    }
  }

  public var eq: String? {
    get {
      return graphQLMap["eq"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var ge: String? {
    get {
      return graphQLMap["ge"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: String? {
    get {
      return graphQLMap["gt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var le: String? {
    get {
      return graphQLMap["le"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: String? {
    get {
      return graphQLMap["lt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ne: String? {
    get {
      return graphQLMap["ne"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var notContains: String? {
    get {
      return graphQLMap["notContains"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notContains")
    }
  }
}

public final class CreateMulticreatorshareddataMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateMulticreatorshareddata($input: CreateMULTICREATORSHAREDDATAInput!) {\n  createMULTICREATORSHAREDDATA(input: $input) {\n    __typename\n    data\n    id\n    version\n  }\n}"

  public var input: CreateMULTICREATORSHAREDDATAInput

  public init(input: CreateMULTICREATORSHAREDDATAInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createMULTICREATORSHAREDDATA", arguments: ["input": GraphQLVariable("input")], type: .object(CreateMulticreatorshareddaTum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createMulticreatorshareddata: CreateMulticreatorshareddaTum? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createMULTICREATORSHAREDDATA": createMulticreatorshareddata.flatMap { $0.snapshot }])
    }

    public var createMulticreatorshareddata: CreateMulticreatorshareddaTum? {
      get {
        return (snapshot["createMULTICREATORSHAREDDATA"] as? Snapshot).flatMap { CreateMulticreatorshareddaTum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createMULTICREATORSHAREDDATA")
      }
    }

    public struct CreateMulticreatorshareddaTum: GraphQLSelectionSet {
      public static let possibleTypes = ["MULTICREATORSHAREDDATA"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("data", type: .scalar(String.self)),
        GraphQLField("id", type: .nonNull(.scalar(String.self))),
        GraphQLField("version", type: .scalar(Int.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(data: String? = nil, id: String, version: Int? = nil) {
        self.init(snapshot: ["__typename": "MULTICREATORSHAREDDATA", "data": data, "id": id, "version": version])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var data: String? {
        get {
          return snapshot["data"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "data")
        }
      }

      public var id: String {
        get {
          return snapshot["id"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var version: Int? {
        get {
          return snapshot["version"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }
    }
  }
}

public final class DeleteMulticreatorshareddataMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteMulticreatorshareddata($input: DeleteMULTICREATORSHAREDDATAInput!) {\n  deleteMULTICREATORSHAREDDATA(input: $input) {\n    __typename\n    data\n    id\n    version\n  }\n}"

  public var input: DeleteMULTICREATORSHAREDDATAInput

  public init(input: DeleteMULTICREATORSHAREDDATAInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteMULTICREATORSHAREDDATA", arguments: ["input": GraphQLVariable("input")], type: .object(DeleteMulticreatorshareddaTum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteMulticreatorshareddata: DeleteMulticreatorshareddaTum? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteMULTICREATORSHAREDDATA": deleteMulticreatorshareddata.flatMap { $0.snapshot }])
    }

    public var deleteMulticreatorshareddata: DeleteMulticreatorshareddaTum? {
      get {
        return (snapshot["deleteMULTICREATORSHAREDDATA"] as? Snapshot).flatMap { DeleteMulticreatorshareddaTum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteMULTICREATORSHAREDDATA")
      }
    }

    public struct DeleteMulticreatorshareddaTum: GraphQLSelectionSet {
      public static let possibleTypes = ["MULTICREATORSHAREDDATA"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("data", type: .scalar(String.self)),
        GraphQLField("id", type: .nonNull(.scalar(String.self))),
        GraphQLField("version", type: .scalar(Int.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(data: String? = nil, id: String, version: Int? = nil) {
        self.init(snapshot: ["__typename": "MULTICREATORSHAREDDATA", "data": data, "id": id, "version": version])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var data: String? {
        get {
          return snapshot["data"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "data")
        }
      }

      public var id: String {
        get {
          return snapshot["id"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var version: Int? {
        get {
          return snapshot["version"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }
    }
  }
}

public final class UpdateMulticreatorshareddataMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateMulticreatorshareddata($input: UpdateMULTICREATORSHAREDDATAInput!) {\n  updateMULTICREATORSHAREDDATA(input: $input) {\n    __typename\n    data\n    id\n    version\n  }\n}"

  public var input: UpdateMULTICREATORSHAREDDATAInput

  public init(input: UpdateMULTICREATORSHAREDDATAInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateMULTICREATORSHAREDDATA", arguments: ["input": GraphQLVariable("input")], type: .object(UpdateMulticreatorshareddaTum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateMulticreatorshareddata: UpdateMulticreatorshareddaTum? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateMULTICREATORSHAREDDATA": updateMulticreatorshareddata.flatMap { $0.snapshot }])
    }

    public var updateMulticreatorshareddata: UpdateMulticreatorshareddaTum? {
      get {
        return (snapshot["updateMULTICREATORSHAREDDATA"] as? Snapshot).flatMap { UpdateMulticreatorshareddaTum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateMULTICREATORSHAREDDATA")
      }
    }

    public struct UpdateMulticreatorshareddaTum: GraphQLSelectionSet {
      public static let possibleTypes = ["MULTICREATORSHAREDDATA"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("data", type: .scalar(String.self)),
        GraphQLField("id", type: .nonNull(.scalar(String.self))),
        GraphQLField("version", type: .scalar(Int.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(data: String? = nil, id: String, version: Int? = nil) {
        self.init(snapshot: ["__typename": "MULTICREATORSHAREDDATA", "data": data, "id": id, "version": version])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var data: String? {
        get {
          return snapshot["data"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "data")
        }
      }

      public var id: String {
        get {
          return snapshot["id"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var version: Int? {
        get {
          return snapshot["version"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }
    }
  }
}

public final class GetMulticreatorshareddataQuery: GraphQLQuery {
  public static let operationString =
    "query GetMulticreatorshareddata($id: String!) {\n  getMULTICREATORSHAREDDATA(id: $id) {\n    __typename\n    data\n    id\n    version\n  }\n}"

  public var id: String

  public init(id: String) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getMULTICREATORSHAREDDATA", arguments: ["id": GraphQLVariable("id")], type: .object(GetMulticreatorshareddaTum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getMulticreatorshareddata: GetMulticreatorshareddaTum? = nil) {
      self.init(snapshot: ["__typename": "Query", "getMULTICREATORSHAREDDATA": getMulticreatorshareddata.flatMap { $0.snapshot }])
    }

    public var getMulticreatorshareddata: GetMulticreatorshareddaTum? {
      get {
        return (snapshot["getMULTICREATORSHAREDDATA"] as? Snapshot).flatMap { GetMulticreatorshareddaTum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getMULTICREATORSHAREDDATA")
      }
    }

    public struct GetMulticreatorshareddaTum: GraphQLSelectionSet {
      public static let possibleTypes = ["MULTICREATORSHAREDDATA"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("data", type: .scalar(String.self)),
        GraphQLField("id", type: .nonNull(.scalar(String.self))),
        GraphQLField("version", type: .scalar(Int.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(data: String? = nil, id: String, version: Int? = nil) {
        self.init(snapshot: ["__typename": "MULTICREATORSHAREDDATA", "data": data, "id": id, "version": version])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var data: String? {
        get {
          return snapshot["data"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "data")
        }
      }

      public var id: String {
        get {
          return snapshot["id"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var version: Int? {
        get {
          return snapshot["version"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }
    }
  }
}

public final class ListMulticreatorshareddatasQuery: GraphQLQuery {
  public static let operationString =
    "query ListMulticreatorshareddatas($filter: TableMULTICREATORSHAREDDATAFilterInput, $limit: Int, $nextToken: String) {\n  listMULTICREATORSHAREDDATAS(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      data\n      id\n      version\n    }\n    nextToken\n  }\n}"

  public var filter: TableMULTICREATORSHAREDDATAFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: TableMULTICREATORSHAREDDATAFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listMULTICREATORSHAREDDATAS", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListMulticreatorshareddata.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listMulticreatorshareddatas: ListMulticreatorshareddata? = nil) {
      self.init(snapshot: ["__typename": "Query", "listMULTICREATORSHAREDDATAS": listMulticreatorshareddatas.flatMap { $0.snapshot }])
    }

    public var listMulticreatorshareddatas: ListMulticreatorshareddata? {
      get {
        return (snapshot["listMULTICREATORSHAREDDATAS"] as? Snapshot).flatMap { ListMulticreatorshareddata(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listMULTICREATORSHAREDDATAS")
      }
    }

    public struct ListMulticreatorshareddata: GraphQLSelectionSet {
      public static let possibleTypes = ["MULTICREATORSHAREDDATAConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .list(.object(Item.selections))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?]? = nil, nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "MULTICREATORSHAREDDATAConnection", "items": items.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?]? {
        get {
          return (snapshot["items"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { Item(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["MULTICREATORSHAREDDATA"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("data", type: .scalar(String.self)),
          GraphQLField("id", type: .nonNull(.scalar(String.self))),
          GraphQLField("version", type: .scalar(Int.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(data: String? = nil, id: String, version: Int? = nil) {
          self.init(snapshot: ["__typename": "MULTICREATORSHAREDDATA", "data": data, "id": id, "version": version])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var data: String? {
          get {
            return snapshot["data"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "data")
          }
        }

        public var id: String {
          get {
            return snapshot["id"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var version: Int? {
          get {
            return snapshot["version"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "version")
          }
        }
      }
    }
  }
}

public final class OnCreateMulticreatorshareddataSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateMulticreatorshareddata($data: String, $id: String) {\n  onCreateMULTICREATORSHAREDDATA(data: $data, id: $id) {\n    __typename\n    data\n    id\n    version\n  }\n}"

  public var data: String?
  public var id: String?

  public init(data: String? = nil, id: String? = nil) {
    self.data = data
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["data": data, "id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateMULTICREATORSHAREDDATA", arguments: ["data": GraphQLVariable("data"), "id": GraphQLVariable("id")], type: .object(OnCreateMulticreatorshareddaTum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateMulticreatorshareddata: OnCreateMulticreatorshareddaTum? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateMULTICREATORSHAREDDATA": onCreateMulticreatorshareddata.flatMap { $0.snapshot }])
    }

    public var onCreateMulticreatorshareddata: OnCreateMulticreatorshareddaTum? {
      get {
        return (snapshot["onCreateMULTICREATORSHAREDDATA"] as? Snapshot).flatMap { OnCreateMulticreatorshareddaTum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateMULTICREATORSHAREDDATA")
      }
    }

    public struct OnCreateMulticreatorshareddaTum: GraphQLSelectionSet {
      public static let possibleTypes = ["MULTICREATORSHAREDDATA"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("data", type: .scalar(String.self)),
        GraphQLField("id", type: .nonNull(.scalar(String.self))),
        GraphQLField("version", type: .scalar(Int.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(data: String? = nil, id: String, version: Int? = nil) {
        self.init(snapshot: ["__typename": "MULTICREATORSHAREDDATA", "data": data, "id": id, "version": version])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var data: String? {
        get {
          return snapshot["data"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "data")
        }
      }

      public var id: String {
        get {
          return snapshot["id"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var version: Int? {
        get {
          return snapshot["version"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }
    }
  }
}

public final class OnDeleteMulticreatorshareddataSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteMulticreatorshareddata($data: String, $id: String) {\n  onDeleteMULTICREATORSHAREDDATA(data: $data, id: $id) {\n    __typename\n    data\n    id\n    version\n  }\n}"

  public var data: String?
  public var id: String?

  public init(data: String? = nil, id: String? = nil) {
    self.data = data
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["data": data, "id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteMULTICREATORSHAREDDATA", arguments: ["data": GraphQLVariable("data"), "id": GraphQLVariable("id")], type: .object(OnDeleteMulticreatorshareddaTum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteMulticreatorshareddata: OnDeleteMulticreatorshareddaTum? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteMULTICREATORSHAREDDATA": onDeleteMulticreatorshareddata.flatMap { $0.snapshot }])
    }

    public var onDeleteMulticreatorshareddata: OnDeleteMulticreatorshareddaTum? {
      get {
        return (snapshot["onDeleteMULTICREATORSHAREDDATA"] as? Snapshot).flatMap { OnDeleteMulticreatorshareddaTum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteMULTICREATORSHAREDDATA")
      }
    }

    public struct OnDeleteMulticreatorshareddaTum: GraphQLSelectionSet {
      public static let possibleTypes = ["MULTICREATORSHAREDDATA"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("data", type: .scalar(String.self)),
        GraphQLField("id", type: .nonNull(.scalar(String.self))),
        GraphQLField("version", type: .scalar(Int.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(data: String? = nil, id: String, version: Int? = nil) {
        self.init(snapshot: ["__typename": "MULTICREATORSHAREDDATA", "data": data, "id": id, "version": version])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var data: String? {
        get {
          return snapshot["data"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "data")
        }
      }

      public var id: String {
        get {
          return snapshot["id"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var version: Int? {
        get {
          return snapshot["version"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }
    }
  }
}

public final class OnUpdateMulticreatorshareddataSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateMulticreatorshareddata($data: String, $id: String) {\n  onUpdateMULTICREATORSHAREDDATA(data: $data, id: $id) {\n    __typename\n    data\n    id\n    version\n  }\n}"

  public var data: String?
  public var id: String?

  public init(data: String? = nil, id: String? = nil) {
    self.data = data
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["data": data, "id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateMULTICREATORSHAREDDATA", arguments: ["data": GraphQLVariable("data"), "id": GraphQLVariable("id")], type: .object(OnUpdateMulticreatorshareddaTum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateMulticreatorshareddata: OnUpdateMulticreatorshareddaTum? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateMULTICREATORSHAREDDATA": onUpdateMulticreatorshareddata.flatMap { $0.snapshot }])
    }

    public var onUpdateMulticreatorshareddata: OnUpdateMulticreatorshareddaTum? {
      get {
        return (snapshot["onUpdateMULTICREATORSHAREDDATA"] as? Snapshot).flatMap { OnUpdateMulticreatorshareddaTum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateMULTICREATORSHAREDDATA")
      }
    }

    public struct OnUpdateMulticreatorshareddaTum: GraphQLSelectionSet {
      public static let possibleTypes = ["MULTICREATORSHAREDDATA"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("data", type: .scalar(String.self)),
        GraphQLField("id", type: .nonNull(.scalar(String.self))),
        GraphQLField("version", type: .scalar(Int.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(data: String? = nil, id: String, version: Int? = nil) {
        self.init(snapshot: ["__typename": "MULTICREATORSHAREDDATA", "data": data, "id": id, "version": version])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var data: String? {
        get {
          return snapshot["data"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "data")
        }
      }

      public var id: String {
        get {
          return snapshot["id"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var version: Int? {
        get {
          return snapshot["version"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }
    }
  }
}
