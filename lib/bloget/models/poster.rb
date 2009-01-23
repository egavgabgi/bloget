module Bloget
  module Models
    module Poster
      def self.included(base)
        base.class_eval do          
          has_one :blogger, :as => :poster
          has_many :posts, :as => :poster
          has_many :comments, :as => :poster
        end
      end
    end
  end
end
