module FrontendApi
  module Commands
    module PositionUpdate
    private

      def update_position(model)
        if permitted_attrs[:position] && permitted_attrs[:position] != ''
          return if permitted_attrs[:position].to_i <= 0

          if model.position.nil?
            max_position = model.class.max(:position) || 0
            if permitted_attrs[:position].to_i > max_position
              @attrs[:position] = max_position + 1
            else
              DB.transaction do
                model.class.where(Sequel.lit("position >= #{permitted_attrs[:position]}")).update(position: Sequel[:position] + 1)
              end
            end
          else
            if model.position != permitted_attrs[:position]
              if model.position > permitted_attrs[:position].to_i
                DB.transaction do
                  model.class.where(Sequel.lit("position >= #{permitted_attrs[:position]}")).where(Sequel.lit("position < #{model.position}")).update(position: Sequel[:position] + 1)
                end
              else
                DB.transaction do
                  model.class.where(Sequel.lit("position <= #{permitted_attrs[:position]}")).where(Sequel.lit("position > #{model.position}")).update(position: Sequel[:position] - 1)
                end
              end
              max_position = model.class.exclude(id: model.id).max(:position) || 1
              @attrs[:position] = max_position + 1 if permitted_attrs[:position].to_i > max_position
            end
          end
        else
          max_position = if model.position != permitted_attrs[:position]
            model.class.exclude(id: model.id).max(:position)
          else
            model.class.max(:position)
          end
          @attrs[:position] = max_position ? max_position + 1 : 1
        end
      end

      def destroy_position(model)
        DB.transaction do
          model.class.where(Sequel.lit("position >= #{model.position}")).update(position: Sequel[:position] - 1)
        end
      end
    end
  end
end
