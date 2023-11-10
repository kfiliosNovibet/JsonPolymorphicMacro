# JsonPolymorphicMacro
#### A Macro to handle Polymorphic Json Decodables

This Macro supports an elegant way to handle polymorphic jsons, 
it removes the decoder code redundancy 

Example: 
Json
```
{
  "type" : "Telephones",
  "cities" : ["Athens", "Krakow", "Catania"],
  "content": {
    "numbers": ["2103722001", "48224202020", "095580014"]
  }
}
```

```
{
  "type" : "Adresses",
  "cities" : ["Athens", "Krakow", "Catania"],
  "content": {
    "adresses": [{"number": "12", "street": "Ermou"}, 
    {"number": "12", "street": "Cable St"}, 
    {"number": "12", "street": "Via Geremila"}]
  }
}
```
## An easy way to handle it with JsonPolyMorphicMacro 

```
protocol Response: Decodable {
}

struct TelephoneResponse: Response {
    let number: [String]?
}

struct AdressesResponse: Response {
    let adresses: [Address]?
}

struct Address: Response {
    let number: String?
    let street: String?
}


@JsonPolymorphicKeys([JsonPolymorphicTypeData(key: "type", polyVarName: "content",
                                              decodableParentType: Response.self,
                                              decodingTypes: ["Telephones":TelephoneResponse.self,
                                                              "Adresses":AdressesResponse.self])])
struct PolyResponse: Decodable {
    let cities: [String]?
}
```

##### The expanded code is 

```
struct PolyResponse: Decodable {
    let cities: [String]?
    let content: Response?

    let type: String?

    enum CodingKeys: String, CodingKey {
        case cities
        case type = "type"
        case content
    }

    init(from decoder: Decoder) throws  {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.cities =  try values.decodeIfPresent([String].self, forKey: .cities)
        self.type =  try values.decodeIfPresent(String.self, forKey: .type)
        switch self.type {
        case "Adresses":
            content = try values.decodeIfPresent(AdressesResponse.self, forKey: .content)
        case "Telephones":
            content = try values.decodeIfPresent(TelephoneResponse.self, forKey: .content)
        default:
            content = nil
        }
    }
}
```
