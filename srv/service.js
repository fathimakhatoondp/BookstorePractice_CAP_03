const { Books, Authors } = require('#cds-models/BookstoreService')
const { Genre } = require('#cds-models/tutorial/db')
const cds = require('@sap/cds')
const { ref } = require('@sap/cds/lib/compile/parse')
const { UPDATE, func } = require('@sap/cds/lib/ql/cds-ql')

module.exports = class BookstoreService extends cds.ApplicationService {
  init() {

    this.on('addStock', Books, async (req) => {
      const bookId = req.params[0].ID;
      console.log(bookId)
      await UPDATE(Books).set({ stock: { '+=': 1 } }).where({ ID: bookId })
      console.log(Books.stock);
    })

    this.on('changePublishedDate', Books, async (req) => {
      const bookId = req.params[0].ID;
      const newDate = req.data.newDate;
      console.log(newDate);
      await UPDATE(Books).set({ publishedAt: newDate }).where({ ID: bookId })
      console.log(Books.publishedAt);
    })

    this.on('changeStatus', Books, async (req) => {
      const bookId = req.params[0].ID;
      const newStatus = req.data.newStatus;
      console.log(newStatus);
      await UPDATE(Books).set({ status_code: newStatus }).where({ ID: bookId })
      console.log(Books.status_code);
    })

    this.on('discount', async () => {
      await UPDATE(Books).set({
        price: {
          func: 'ROUND',
          args: [{
            xpr: [{ ref: ['price'] }, '*',
            { val: 0.9 }]
          },
          { val: 2 }]
        }
      })
    })

    this.before('READ', Books, async (req) => {
      console.log('Before READ Books', req.data)
    })

    this.after('READ', Books, async (books, req) => {
      for (const book of books) {
        if (book.genre_code === Genre.Art) {
          book.price = Number(book.price * 0.9).toFixed(2);
        }
      }
    })
    this.after('READ', Authors, async (authors) => {
      const ids = authors.map(author => author.ID);
      const bookCounts = await SELECT.from(Books)
        .columns('author_ID',{func:'count'})
        .where({ author_ID:{in: ids}})
        .groupBy('author_ID');
      for (const author of authors) {
        const bookCount = bookCounts.find(count => count.author_ID === author.ID);
        author.bookCount = bookCount ? bookCount.count : 0;
      }
    });
    return super.init()
  }
}
