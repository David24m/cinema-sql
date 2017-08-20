require_relative("../db/sql_runner")
require_relative('films')

class Customer

  attr_reader :id
  attr_accessor :name, :fund

  def initialize( options )
    @id = options['id'].to_i
    @name = options['name']
    @fund = options['fund']
  end

  def save()
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = "INSERT INTO customers
    (
      name, fund
    )
      VALUES
    (
      $1, $2
    )
    RETURNING id"
    values = [@name, @fund]
    user = SqlRunner.run( sql, values ).first
    @id = user['id'].to_i
  end

  def Customer.all()
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = "SELECT * FROM customers"
    values = []
    locations = SqlRunner.run(sql, values)
    result = Customer.map_items(customers)
    return result
  end

  def Customer.delete_all()
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = "DELETE FROM customers"
    values = []
    SqlRunner.run(sql, values)
  end

  def delete()
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = "DELETE FROM customers
    WHERE id = $1"
    values =[@id]
    SqlRunner.run(sql, values)
  end

  def update()
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = "
    UPDATE customers
    SET (name, fund)
    =
    ($1, $2)
    WHERE id = $3
    "
    values = [@name, @fund, @id]
    SqlRunner.run(sql, values)
  end

  def films
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = '
      SELECT films.* FROM films
        INNER JOIN tickets ON tickets.film_id = films.id
        WHERE customer_id = $1
    '
    values = [@id]
    results = SqlRunner.run(sql, values)
    return Film.map_items(results)
  end

  def Customer.map_items(rows)
    return rows.map { |row| Customer.new(row) }
  end

  def buy_ticket(film)
    ticket1 = Ticket.new({ 'customer_id' => @id, 'film_id' => film.id})
    ticket1.save()
    @fund = @fund - film.price
  end

  def films_seen
    films.length
  end

end
