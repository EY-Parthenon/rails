require 'test/unit'
require File.dirname(__FILE__) + '/../../lib/action_view/helpers/date_helper'
require File.dirname(__FILE__) + '/../../lib/action_view/helpers/form_helper'
require File.dirname(__FILE__) + '/../../lib/action_view/helpers/text_helper'
require File.dirname(__FILE__) + '/../../lib/action_view/helpers/tag_helper'
require File.dirname(__FILE__) + '/../../lib/action_view/helpers/url_helper'
# require File.dirname(__FILE__) + '/../../lib/action_view/helpers/active_record_helper'

class ActiveRecordHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::ActiveRecordHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper

  Post   = Struct.new("Post", :title, :author_name, :body, :secret, :written_on)
  Post.class_eval do
    alias_method :title_before_type_cast, :title unless respond_to?(:title_before_type_cast)
    alias_method :body_before_type_cast, :body unless respond_to?(:body_before_type_cast)
    alias_method :author_name_before_type_cast, :author_name unless respond_to?(:author_name_before_type_cast)
  end
  Column = Struct.new("Column", :type, :name, :human_name)

  def setup
    @post = Post.new    
    def @post.errors
      Class.new {
        def on(field) field == "author_name" || field == "body" end
        def empty?() false end 
        def count() 1 end 
        def full_messages() [ "Author name can't be empty" ] end
      }.new
    end
    
    def @post.new_record?() true end

    def @post.column_for_attribute(attr_name)
      Post.content_columns.select { |column| column.name == attr_name }.first
    end

    def Post.content_columns() [ Column.new(:string, "title", "Title"), Column.new(:text, "body", "Body") ] end

    @post.title       = "Hello World"
    @post.author_name = ""
    @post.body        = "Back to the hill and over it again!"
    @post.secret = 1
    @post.written_on  = Date.new(2004, 6, 15)

    @controller = Class.new do
      def url_for(options, *parameters_for_method_reference)
        options[:action] || options["action"]
      end
    end
    @controller = @controller.new
  end

  def test_generic_input_tag
    assert_equal(
      %(<input id="post_title" name="post[title]" size="30" type="text" value="Hello World" />), input("post", "title")
    )
  end
  
  def test_text_area_with_errors
    assert_equal(
      %(<div class="fieldWithErrors"><textarea cols="40" id="post_body" name="post[body]" rows="20" wrap="virtual">Back to the hill and over it again!</textarea></div>),
      text_area("post", "body")
    )    
  end

  def test_text_field_with_errors
    assert_equal(
      %(<div class="fieldWithErrors"><input id="post_author_name" name="post[author_name]" size="30" type="text" value="" /></div>),
      text_field("post", "author_name")
    )
  end
  
  def test_form_with_string
    assert_equal(
      %(<form action="create" method="post"><p><label for="post_title">Title</label><br /><input id="post_title" name="post[title]" size="30" type="text" value="Hello World" /></p>\n<p><label for="post_body">Body</label><br /><div class="fieldWithErrors"><textarea cols="40" id="post_body" name="post[body]" rows="20" wrap="virtual">Back to the hill and over it again!</textarea></div></p><input type="submit" value="Create" /></form>),
      form("post")
    )
  end
  
  def test_form_with_date
    def Post.content_columns() [ Column.new(:date, "written_on", "Written on") ] end

    assert_equal(
      %(<form action="create" method="post"><p><label for="post_written_on">Written on</label><br /><select name="post[written_on(1i)]">\n<option value="1999">1999</option>\n<option value="2000">2000</option>\n<option value="2001">2001</option>\n<option value="2002">2002</option>\n<option value="2003">2003</option>\n<option value="2004" selected="selected">2004</option>\n<option value="2005">2005</option>\n<option value="2006">2006</option>\n<option value="2007">2007</option>\n<option value="2008">2008</option>\n<option value="2009">2009</option>\n</select>\n<select name="post[written_on(2i)]">\n<option value="1">January</option>\n<option value="2">February</option>\n<option value="3">March</option>\n<option value="4">April</option>\n<option value="5">May</option>\n<option value="6" selected="selected">June</option>\n<option value="7">July</option>\n<option value="8">August</option>\n<option value="9">September</option>\n<option value="10">October</option>\n<option value="11">November</option>\n<option value="12">December</option>\n</select>\n<select name="post[written_on(3i)]">\n<option value="1">1</option>\n<option value="2">2</option>\n<option value="3">3</option>\n<option value="4">4</option>\n<option value="5">5</option>\n<option value="6">6</option>\n<option value="7">7</option>\n<option value="8">8</option>\n<option value="9">9</option>\n<option value="10">10</option>\n<option value="11">11</option>\n<option value="12">12</option>\n<option value="13">13</option>\n<option value="14">14</option>\n<option value="15" selected="selected">15</option>\n<option value="16">16</option>\n<option value="17">17</option>\n<option value="18">18</option>\n<option value="19">19</option>\n<option value="20">20</option>\n<option value="21">21</option>\n<option value="22">22</option>\n<option value="23">23</option>\n<option value="24">24</option>\n<option value="25">25</option>\n<option value="26">26</option>\n<option value="27">27</option>\n<option value="28">28</option>\n<option value="29">29</option>\n<option value="30">30</option>\n<option value="31">31</option>\n</select>\n</p><input type="submit" value="Create" /></form>),
      form("post")
    )
  end
  
  def test_form_with_datetime
    def Post.content_columns() [ Column.new(:datetime, "written_on", "Written on") ] end
    @post.written_on  = Time.gm(2004, 6, 15, 16, 30)

    assert_equal(
      %(<form action="create" method="post"><p><label for="post_written_on">Written on</label><br /><select name="post[written_on(1i)]">\n<option value="1999">1999</option>\n<option value="2000">2000</option>\n<option value="2001">2001</option>\n<option value="2002">2002</option>\n<option value="2003">2003</option>\n<option value="2004" selected="selected">2004</option>\n<option value="2005">2005</option>\n<option value="2006">2006</option>\n<option value="2007">2007</option>\n<option value="2008">2008</option>\n<option value="2009">2009</option>\n</select>\n<select name="post[written_on(2i)]">\n<option value="1">January</option>\n<option value="2">February</option>\n<option value="3">March</option>\n<option value="4">April</option>\n<option value="5">May</option>\n<option value="6" selected="selected">June</option>\n<option value="7">July</option>\n<option value="8">August</option>\n<option value="9">September</option>\n<option value="10">October</option>\n<option value="11">November</option>\n<option value="12">December</option>\n</select>\n<select name="post[written_on(3i)]">\n<option value="1">1</option>\n<option value="2">2</option>\n<option value="3">3</option>\n<option value="4">4</option>\n<option value="5">5</option>\n<option value="6">6</option>\n<option value="7">7</option>\n<option value="8">8</option>\n<option value="9">9</option>\n<option value="10">10</option>\n<option value="11">11</option>\n<option value="12">12</option>\n<option value="13">13</option>\n<option value="14">14</option>\n<option value="15" selected="selected">15</option>\n<option value="16">16</option>\n<option value="17">17</option>\n<option value="18">18</option>\n<option value="19">19</option>\n<option value="20">20</option>\n<option value="21">21</option>\n<option value="22">22</option>\n<option value="23">23</option>\n<option value="24">24</option>\n<option value="25">25</option>\n<option value="26">26</option>\n<option value="27">27</option>\n<option value="28">28</option>\n<option value="29">29</option>\n<option value="30">30</option>\n<option value="31">31</option>\n</select>\n &mdash; <select name="post[written_on(4i)]">\n<option value="00">00</option>\n<option value="01">01</option>\n<option value="02">02</option>\n<option value="03">03</option>\n<option value="04">04</option>\n<option value="05">05</option>\n<option value="06">06</option>\n<option value="07">07</option>\n<option value="08">08</option>\n<option value="09">09</option>\n<option value="10">10</option>\n<option value="11">11</option>\n<option value="12">12</option>\n<option value="13">13</option>\n<option value="14">14</option>\n<option value="15">15</option>\n<option value="16" selected="selected">16</option>\n<option value="17">17</option>\n<option value="18">18</option>\n<option value="19">19</option>\n<option value="20">20</option>\n<option value="21">21</option>\n<option value="22">22</option>\n<option value="23">23</option>\n</select>\n : <select name="post[written_on(5i)]">\n<option value="00">00</option>\n<option value="01">01</option>\n<option value="02">02</option>\n<option value="03">03</option>\n<option value="04">04</option>\n<option value="05">05</option>\n<option value="06">06</option>\n<option value="07">07</option>\n<option value="08">08</option>\n<option value="09">09</option>\n<option value="10">10</option>\n<option value="11">11</option>\n<option value="12">12</option>\n<option value="13">13</option>\n<option value="14">14</option>\n<option value="15">15</option>\n<option value="16">16</option>\n<option value="17">17</option>\n<option value="18">18</option>\n<option value="19">19</option>\n<option value="20">20</option>\n<option value="21">21</option>\n<option value="22">22</option>\n<option value="23">23</option>\n<option value="24">24</option>\n<option value="25">25</option>\n<option value="26">26</option>\n<option value="27">27</option>\n<option value="28">28</option>\n<option value="29">29</option>\n<option value="30" selected="selected">30</option>\n<option value="31">31</option>\n<option value="32">32</option>\n<option value="33">33</option>\n<option value="34">34</option>\n<option value="35">35</option>\n<option value="36">36</option>\n<option value="37">37</option>\n<option value="38">38</option>\n<option value="39">39</option>\n<option value="40">40</option>\n<option value="41">41</option>\n<option value="42">42</option>\n<option value="43">43</option>\n<option value="44">44</option>\n<option value="45">45</option>\n<option value="46">46</option>\n<option value="47">47</option>\n<option value="48">48</option>\n<option value="49">49</option>\n<option value="50">50</option>\n<option value="51">51</option>\n<option value="52">52</option>\n<option value="53">53</option>\n<option value="54">54</option>\n<option value="55">55</option>\n<option value="56">56</option>\n<option value="57">57</option>\n<option value="58">58</option>\n<option value="59">59</option>\n</select>\n</p><input type="submit" value="Create" /></form>),
      form("post")
    )
  end
  
  def test_error_for_block
    assert_equal %(<div class="errorExplanation" id="errorExplanation"><h2>1 error prohibited this post from being saved</h2><p>There were problems with the following fields:</p><ul><li>Author name can't be empty</li></ul></div>), error_messages_for("post")
    assert_equal %(<div class="errorDeathByClass" id="errorDeathById"><h1>1 error prohibited this post from being saved</h1><p>There were problems with the following fields:</p><ul><li>Author name can't be empty</li></ul></div>), error_messages_for("post", :class => "errorDeathByClass", :id => "errorDeathById", :header_tag => "h1")
  end
end
