use super::writer::IDRISDBWriter;
use crate::core::error::Result;

pub trait IDRISDBInsert<'a>: IDRISDBWriter<'a> + Sized {
    type Txn;

    fn save(&mut self, id: i64) -> Result<()>;

    fn finish(self) -> Result<Self::Txn>;
}
