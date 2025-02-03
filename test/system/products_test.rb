require "application_system_test_case"

class ProductsTest < ApplicationSystemTestCase
  setup do
    @product = products(:one)
  end

  test "visiting the index" do
    visit products_url
    assert_selector "h1", text: "Products"
  end

  test "should create product" do
    visit products_url
    click_on "New product"

    fill_in "Full address", with: @product.full_address
    fill_in "Imageentregador", with: @product.imageEntregador
    fill_in "Imageinvoice", with: @product.imageInvoice
    fill_in "Imageproduct", with: @product.imageProduct
    fill_in "Locker code", with: @product.locker_code
    fill_in "Package description", with: @product.package_description
    fill_in "Pin", with: @product.pin
    click_on "Create Product"

    assert_text "Product was successfully created"
    click_on "Back"
  end

  test "should update Product" do
    visit product_url(@product)
    click_on "Edit this product", match: :first

    fill_in "Full address", with: @product.full_address
    fill_in "Imageentregador", with: @product.imageEntregador
    fill_in "Imageinvoice", with: @product.imageInvoice
    fill_in "Imageproduct", with: @product.imageProduct
    fill_in "Locker code", with: @product.locker_code
    fill_in "Package description", with: @product.package_description
    fill_in "Pin", with: @product.pin
    click_on "Update Product"

    assert_text "Product was successfully updated"
    click_on "Back"
  end

  test "should destroy Product" do
    visit product_url(@product)
    click_on "Destroy this product", match: :first

    assert_text "Product was successfully destroyed"
  end
end
