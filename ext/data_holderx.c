#include "data_holderx.h"

static VALUE rb_DataHolderC;

struct data {
  double instant;
};

struct data_array {
  struct data[] data;
  int size;
};

static void data_mark(struct data **d) {
}

static void data_free(struct data **d) {
  // free stuff
}

static VALUE data_holder_allocate(VALUE klass) {
  struct data_array *d = malloc(sizeof(*d));
  return Data_Wrap_Struct(klass, data_mark, data_free, d);
}

static VALUE data_holder_initialize(VALUE klass, int size) {
  struct data_array *d;
  Data_Get_Struct(klass, struct data_array, *d);
  d->data = malloc(sizeof(struct data) * size);
  d->size = size;
  return klass;
}

void Init_data_holderx()
{
  rb_DataHolderC = rb_define_class("DataHolderC", rb_cObject);
  rb_define_alloc_func(rb_DataHolderC, data_holder_allocate);
  rb_define_method(rb_DataHolderC, "initialize", data_holder_initialize, 1);
}
