import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/product_provider.dart';

class EditProduct extends StatefulWidget {
  static const routeName = "/edit-product";

  EditProduct({Key? key}) : super(key: key);

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var newProduct =
      Product(id: "", title: "", description: "", price: 0, imageUrl: "");
  bool _isInit = true;
  var _initValues = {
    "title": "",
    "description": "",
    "price": "",
    "imageUrl": ""
  };
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    if (this._isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments as String?;
      if (productId != null) {
        this.newProduct = Provider.of<ProductProvider>(context, listen: false)
            .findById(productId);
        this._initValues = {
          "title": this.newProduct.title,
          "description": this.newProduct.description,
          "price": this.newProduct.price.toString(),
          // "imageUrl": this.newProduct.imageUrl,
        };
        _imageUrlController.text = this.newProduct.imageUrl;
      }
    }
    this._isInit = false;
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!this._imageUrlController.text.startsWith("http") &&
              !this._imageUrlController.text.startsWith("https")) ||
          (!this._imageUrlController.text.endsWith("png") &&
              !this._imageUrlController.text.endsWith("jpg") &&
              !this._imageUrlController.text.endsWith("jpeg"))) {
        return;
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    this._priceFocusNode.dispose();
    this._descriptionFocusNode.dispose();
    this._imageUrlController.dispose();
    this._imageUrlFocusNode.dispose();
    super.dispose();
  }

  // void _saveForm() {
  //   if (!this._form.currentState!.validate()) {
  //     return;
  //   }
  //   this._form.currentState!.save();
  //   setState(() {
  //     this.isLoading = true;
  //   });
  //   if (this.newProduct.id.isEmpty) {
  //     Provider.of<ProductProvider>(context, listen: false)
  //         .addProduct(newProduct)
  //         .catchError((error) {
  //       return showDialog(
  //           context: context,
  //           builder: (ctx) {
  //             return AlertDialog(
  //               title: Text("An Error occurred!"),
  //               content: Text(error.toString()),
  //               actions: [
  //                 FlatButton(
  //                     onPressed: () {
  //                       Navigator.of(ctx).pop();
  //                     },
  //                     child: Text("OKAY"))
  //               ],
  //             );
  //           });
  //     }).then((_) {
  //       setState(() {
  //         this.isLoading = false;
  //       });
  //       Navigator.of(context).pop();
  //     });
  //   } else {
  //     Provider.of<ProductProvider>(context, listen: false)
  //         .updateProduct(this.newProduct.id, this.newProduct);
  //     setState(() {
  //       this.isLoading = false;
  //     });
  //     Navigator.of(context).pop();
  //   }
  // }

  Future<void> _saveForm() async {
    if (!this._form.currentState!.validate()) {
      return;
    }
    this._form.currentState!.save();
    setState(() {
      this.isLoading = true;
    });
    if (this.newProduct.id.isEmpty) {
      try {
        await Provider.of<ProductProvider>(context, listen: false)
            .addProduct(newProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text("An Error occurred!"),
                content: Text(error.toString()),
                actions: [
                  FlatButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text("OKAY"))
                ],
              );
            });
      }
    } else {
      try {
        await Provider.of<ProductProvider>(context, listen: false)
            .updateProduct(this.newProduct.id, this.newProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text("An Error occurred!"),
                content: Text(error.toString()),
                actions: [
                  FlatButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text("OKAY"))
                ],
              );
            });
      }
    }
    setState(() {
      this.isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))],
      ),
      body: (isLoading)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: this._form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: this._initValues["title"],
                      decoration: InputDecoration(labelText: "Title"),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Invalid";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        this.newProduct = Product(
                            id: this.newProduct.id,
                            title: newValue!,
                            description: this.newProduct.description,
                            price: this.newProduct.price,
                            imageUrl: this.newProduct.imageUrl,
                            isFavorite: this.newProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: this._initValues["price"],
                      decoration: InputDecoration(labelText: "Price"),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter a price.";
                        }
                        if (double.tryParse(value) == null) {
                          return "Please enter a valid number";
                        }
                        if (double.parse(value) <= 0) {
                          return "Please enter a number greater than 0";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        this.newProduct = Product(
                            id: this.newProduct.id,
                            title: this.newProduct.title,
                            description: this.newProduct.description,
                            price: double.parse(newValue!),
                            imageUrl: this.newProduct.imageUrl,
                            isFavorite: this.newProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: this._initValues["description"],
                      decoration: InputDecoration(labelText: "Description"),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter a description";
                        }
                        if (value.length < 10) {
                          return "Should be atlease 10 characters long.";
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      focusNode: _descriptionFocusNode,
                      onSaved: (newValue) {
                        this.newProduct = Product(
                            id: this.newProduct.id,
                            title: this.newProduct.title,
                            description: newValue!,
                            price: this.newProduct.price,
                            imageUrl: this.newProduct.imageUrl,
                            isFavorite: this.newProduct.isFavorite);
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey)),
                          child: _imageUrlController.text.isEmpty
                              ? Text("Enter an image url")
                              : FittedBox(
                                  child:
                                      Image.network(_imageUrlController.text),
                                  fit: BoxFit.fill,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            // initialValue: this._initValues["imageUrl"],
                            decoration: InputDecoration(labelText: "Image Url"),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (value) {
                              this._saveForm();
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter an image url";
                              }
                              if (!value.startsWith("http") &&
                                  !value.startsWith("https")) {
                                return "Please enter a valid image url";
                              }
                              if (!value.endsWith("png") &&
                                  !value.endsWith("jpg") &&
                                  !value.endsWith("jpeg")) {
                                return "Please enter a valid image url";
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              this.newProduct = Product(
                                  id: this.newProduct.id,
                                  title: this.newProduct.title,
                                  description: this.newProduct.description,
                                  price: this.newProduct.price,
                                  imageUrl: newValue!,
                                  isFavorite: this.newProduct.isFavorite);
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
