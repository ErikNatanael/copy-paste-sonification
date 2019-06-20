extern crate serde;
extern crate serde_json;
use serde::{Deserialize, Serialize};
use std::io::prelude::*;
use std::fs::File;
use std::io::Read;
use std::collections::HashMap;

#[derive(Serialize, Deserialize)]
struct NodeRepresentation {
    source: String,
    name: String,
    children: Vec<NodeRepresentation>,
}

struct NodeData {
    depth: i32,
    name: String,
    number_of_children: i32,
}


fn main() {
    let file = File::open("data.json")
        .expect("file should open read only");
    
    let data_tree: NodeRepresentation = serde_json::from_reader(file)
        .expect("file should be proper JSON");
        
    let mut map: HashMap<String, i32> = HashMap::new();
    
    count_words(&data_tree, &mut map);
    
    // convert HashMap to Vec
    let mut word_vec: Vec<(String, &i32)> = map
        .iter()
        .map(|(name, count)| (name.clone(), count))
        .collect();
    
    word_vec.sort_unstable_by(|a, b| b.1.cmp(a.1)); // sort by number of occurences
    
    // write results to a file
    let mut out_file = File::create("word_count.txt").expect("Could not open file");
    
    for tuple in word_vec {
        println!("{}: {}", tuple.0, tuple.1);
        writeln!(out_file, "{}: {}", tuple.0, tuple.1).expect("Could not write to file");
    }
    
    // rewrite data in a different structure
}

// count the amount of times a single word occurs in any name
fn count_words(data_tree: &NodeRepresentation, map: &mut HashMap<String, i32>) {
    let words: Vec<String> = data_tree.name
        .split(|c| c == '.') // add more split signs using the closure
        .map(|c| c.to_owned()) // convert from &str to String
        .collect();
    // add to HashMap if it is not already added and increase counter
    for word in words {
        let count = map.entry(word).or_insert(0);
        *count += 1;
    }
    // do recursively for all child nodes
    for child in &data_tree.children {
        count_words(&child, map);
    }
}


fn write_data_to_file(data_tree: &NodeRepresentation) {
    let mut out_file = File::create("data_remade.txt").expect("Could not open file");
}
