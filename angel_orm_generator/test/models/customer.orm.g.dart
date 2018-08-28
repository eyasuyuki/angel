// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// OrmGenerator
// **************************************************************************

import 'customer.dart';
import 'dart:async';
import 'package:postgres/postgres.dart';
part 'customer.postgresql.orm.g.dart';

abstract class CustomerOrm {
  factory CustomerOrm.postgreSql(PostgreSQLConnection connection) =
      _PostgreSqlCustomerOrmImpl;

  Future<List<Customer>> getAll();
  Future<Customer> getById(id);
  Future<Customer> update(Customer model);
  CustomerQuery query();
}

class CustomerQuery {}
