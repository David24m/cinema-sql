require_relative("../db/sql_runner")
require_relative('customers')

class Film

  attr_reader :id
  attr_accessor :name, :price

  def initialize( options )
    @id = options['id'].to_i
    @name = options['name']
    @price = options['price']
  end
  def save()
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = "INSERT INTO films
    (
      name, price
    )
      VALUES
    (
      $1, $2
    )
    RETURNING id"
    values = [@name, @price]
    user = SqlRunner.run( sql, values ).first
    @id = user['id'].to_i
  end

  def Film.all()
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = "SELECT * FROM films"
    values = []
    locations = SqlRunner.run(sql, values)
    result = Film.map_items(films)
    return result
  end

  def Film.delete_all()
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = "DELETE FROM films"
    values = []
    SqlRunner.run(sql, values)
  end

  def delete()
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = "DELETE FROM films
    WHERE id = $1"
    values = [@id]
    SqlRunner.run(sql, values)
  end

  def update()
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = "UPDATE films
    SET (name, price)
    =
    ($1, $2)
    WHERE id = $3
    "
    values = [@name, @price, @id]
    SqlRunner.run(sql, values)
  end

  def customers
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = '
      SELECT customers.* FROM customers
        INNER JOIN tickets ON tickets.customer_id = customers.id
        WHERE film_id = $1
    '
    values = [@id]
    results = SqlRunner.run(sql, values)
    return Customer.map_items(results)
  end

  def Film.map_items(rows)
    return rows.map { |row| Film.new(row) }
  end

  def customers_present
    customers.length
  end

  def screenings
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = '
      SELECT screenings.* FROM screenings
        INNER JOIN tickets ON tickets.screening_id = screenings.id
    '
    values = []
    results = SqlRunner.run(sql, values)
    return results
  end

end
