use serde::{Deserialize, Serialize};

use crate::layouts::Layout;
use crate::models::Size;

#[derive(Serialize, Default, Deserialize, Debug, Clone, PartialEq)]
pub struct Workspace {
    pub x: Option<i32>,
    pub y: Option<i32>,
    pub height: Option<i32>,
    pub width: Option<i32>,
    pub id: Option<i32>,
    pub output_name: Option<String>,
    pub max_window_width: Option<Size>,
    pub layouts: Option<Vec<Layout>>,
}
