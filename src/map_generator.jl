function future_position(point, direction)
    if direction == 0
        point += CartesianIndex(-1,  0)
    elseif direction == 1
        point += CartesianIndex( 0, -1)
    elseif direction == 2
        point += CartesianIndex( 1,  0)
    else
        point += CartesianIndex( 0,  1)
    end
    return point
end

function get_bound(env, transform, idx_transform = identity)
    for (i, x) in enumerate(transform(env))
        any(x .!= 0) && return idx_transform(i)
    end
end

function generate_map()
    while true
        env = zeros(Int, 30, 30)
        point = rand(CartesianIndices((1:30, 1:30)))
        tile = rand(1:3)
        dir  = rand(0:3)
        env[point] = 10 * tile + dir
        iter = 1
        while true
            if tile == 2
                dir = (dir + 1) % 4
            elseif tile == 3
                dir = dir == 0 ? 3 : (dir - 1)
            end
            tile = rand(1:3)
            point = future_position(point, dir)
            if 1 <= point.I[1] <= 30 && 1 <= point.I[2] <= 30
		        temp = future_position(point, dir)
		        if 1 <= temp.I[1] <= 30 && 1 <= temp.I[2] <= 30
		            if env[temp] == 0
		                env[point] = 10 * tile + dir
		            else
		                if tile == 2
		                    dir_future = (dir + 1) % 4
		                elseif tile == 3
		                    dir_future = dir == 0 ? 3 : (dir - 1)
		                else
		                    dir_future = dir
		                end
		                if dir_future == env[temp] % 10
		                    env[point] = 10 * tile + dir
		                end
		                break
		            end
		        else
		            env[point] = 10 * tile + dir
		            break
		        end
		    else
		        break
		    end
            iter += 1
        end
        if iter >= 20
            i_min = get_bound(env, eachrow)
            i_max = get_bound(env, x -> eachrow(reverse(x, dims = 1)),
                              i -> 31 - i)
            j_min = get_bound(env, eachcol)
            j_max = get_bound(env, x -> eachcol(reverse(x, dims = 2)),
                              i -> 31 - i)
            for i in i_min:i_max,
                j in j_min:j_max
                if env[i, j] == 0
                    env[i, j] = rand(1:3)
                end
            end
            return env[i_min:i_max, j_min:j_max]
        end
    end
end

function interpret_number(val)
    txt = ""
    tile = val ÷ 10
    dir  = val % 10
    if val == 1
        return "floor"
    elseif val == 2
        return "asphalt"
    elseif val == 3
        return "grass"
    end
    if tile == 1
        txt *= "straight"
    elseif tile == 2
        txt *= "curve_left"
    elseif tile == 3
        txt *= "curve_right"
    end
    txt *= "/"
    if dir == 0
        txt *= "N"
    elseif dir == 1
        txt *= "W"
    elseif dir == 2
        txt *= "S"
    else
        txt *= "E"
    end
    return txt
end

generate_random_track() = [row for row in eachrow(interpret_number.(generate_map()))]
