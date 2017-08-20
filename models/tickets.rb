require_relative("../db/sql_runner")
require_relative("customers")
require_relative("films")
require_relative("screenings")

class Ticket

  attr_reader :id
  attr_accessor :customer_id, :film_id, :screening_id

  def initialize( options )
    @id = options['id'].to_i
    @customer_id = options['customer_id'].to_i
    @film_id = options['film_id'].to_i
    @screening_id = options['screening_id'].to_i
  end

  def save()
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = "INSERT INTO tickets
    (
      customer_id,
      film_id,
      screening_id
    )
    VALUES
    (
      $1, $2, $3
    )
    RETURNING id"
    values = [@customer_id, @film_id, @screening_id]
    ticket = SqlRunner.run( sql,values ).first
    @id = ticket['id'].to_i
  end

  def Ticket.all()
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = "SELECT * FROM tickets"
    values = []
    tickets = SqlRunner.run(sql, values)
    result = tickets.map { |ticket| Ticket.new( ticket ) }
    return result
  end

  def Ticket.delete_all()
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = "DELETE FROM tickets"
    values = []
    SqlRunner.run(sql, values)
  end

  def delete()
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = "DELETE FROM tickets
    WHERE id = $1"
    values = [@id]
    SqlRunner.run(sql, values)
  end

  def update()
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = "UPDATE tickets
    SET (customer_id, film_id, screening_id)
    =
    ($1, $2, $3)
    WHERE id = $4
    "
    values = [@customer_id, @film_id, @screening_id]
    SqlRunner.run(sql, values)
  end

  def customers()
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = 'SELECT * FROM customers
    WHERE id = $1;'
    values = [@customer_id]
    result = SqlRunner.run(sql, values)
    return Customer.new(result[0])
  end

  def films()
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = 'SELECT * FROM films
    WHERE id = $1;'
    values = [@film_id]
    result = SqlRunner.run(sql, values)
    return Film.new(result[0])
  end

  def screenings()
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = 'SELECT * FROM screenings
    WHERE id = $1;'
    values = [@screening_id]
    result = SqlRunner.run(sql, values)
    return Screening.new(result[0])
  end

  def popular
    customers.screenings.id
  end



end
