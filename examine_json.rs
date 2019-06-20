extern crate serde;
extern crate serde_json;

fn main() {
    let file = fs::File::open("data.json")
        .expect("file should open read only");
    let json: serde_json::Value = serde_json::from_reader(file)
        .expect("file should be proper JSON");
    let first_name = json.get("FirstName")
        .expect("file should have FirstName key");
}
