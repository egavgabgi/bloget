module Bloget
  module Models
    module Post
      
      def self.included(base)
        base.class_eval do
          
          has_many :comments, :order => 'created_at ASC'
          belongs_to :poster, :polymorphic => true

          validates_presence_of :poster_id
          validates_presence_of :poster_type
          validates_presence_of :title
          validates_presence_of :permalink
          validates_uniqueness_of :permalink
          validates_format_of :permalink, :with => /^[\w\-]+$/,
          :message => 'must only be made up of numbers, letters, and dashes'

          named_scope :published, { :conditions => ['published = ?', true] }
          named_scope :draft, { :conditions => ['published = ?', false] }
          named_scope :chronologically, { :order => 'created_at DESC' }
        end        
      end
      
      def to_param
        permalink
      end
      
      def display_title
        title = read_attribute(:title)
        title += " [DRAFT]" if !title.empty? and draft?
        title
      end

      def publish
        update_attribute(:published, true)
      end

      alias :publish! :publish

      def unpublish
        update_attribute(:published, false)
      end

      alias :unpublish! :unpublish

      def draft?
        !published?
      end

      def state
        published? ? 'published' : 'draft'
      end
      
    end
  end
end
