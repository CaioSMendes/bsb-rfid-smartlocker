require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:one)
  end

  test "should get index" do
    get products_url
    assert_response :success
  end

  test "should get new" do
    get new_product_url
    assert_response :success
  end

  test "should create product" do
    assert_difference("Product.count") do
      post products_url, params: { product: { full_address: @product.full_address, imageEntregador: @product.imageEntregador, imageInvoice: @product.imageInvoice, imageProduct: @product.imageProduct, locker_code: @product.locker_code, package_description: @product.package_description, pin: @product.pin } }
    end

    assert_redirected_to product_url(Product.last)
  end

  test "should show product" do
    get product_url(@product)
    assert_response :success
  end

  test "should get edit" do
    get edit_product_url(@product)
    assert_response :success
  end

  test "should update product" do
    patch product_url(@product), params: { product: { full_address: @product.full_address, imageEntregador: @product.imageEntregador, imageInvoice: @product.imageInvoice, imageProduct: @product.imageProduct, locker_code: @product.locker_code, package_description: @product.package_description, pin: @product.pin } }
    assert_redirected_to product_url(@product)
  end

  test "should destroy product" do
    assert_difference("Product.count", -1) do
      delete product_url(@product)
    end

    assert_redirected_to products_url
  end
end
