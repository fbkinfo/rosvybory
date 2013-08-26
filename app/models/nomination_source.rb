class NominationSource < ActiveRecord::Base
  KNOWN_VARIANTS = %w{candidate party parliament}

  has_many :user_current_roles

  validates :name, presence: true
  validates :variant, presence: true, inclusion: {in: KNOWN_VARIANTS}

  class <<self
    def human_variant(s)
      human_attribute_name("variants.#{s}") if s.present?
    end

    def variants_with_names
      KNOWN_VARIANTS.map {|v| [human_variant(v), v] }
    end
  end

  def human_variant
    selff.class.human_variant(variant)
  end
end
